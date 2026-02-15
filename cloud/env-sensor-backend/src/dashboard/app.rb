# frozen_string_literal: true

require 'erb'
require 'json'
require 'aws-sdk-dynamodb'

ONE_DAY_AGO = (Time.now - (60 * 60 * 24)).to_i * 1000

def dynamodb_table
  table_name = ENV.fetch('SENSOR_READINGS_TABLE', '')
  Aws::DynamoDB::Table.new(table_name)
end

def device_ids
  res = dynamodb_table.scan(
    projection_expression: :device_id,
    filter_expression: '#TS > :timestamp',
    expression_attribute_values: { ':timestamp' => ONE_DAY_AGO },
    expression_attribute_names: { '#TS' => 'timestamp' }
  )
  res.items.map { it['device_id'] }.uniq
end

def records_for_device(device_id)
  res = dynamodb_table.query(
    key_condition_expression: 'device_id = :device_id AND #TS > :timestamp',
    expression_attribute_values: { ':device_id' => device_id, ':timestamp' => ONE_DAY_AGO },
    expression_attribute_names: { '#TS' => 'timestamp' }
  )
  res.items
end

def response_html(body)
  {
    statusCode: 200,
    headers: { 'Content-Type': 'text/html' },
    body:
  }
end

def handler(event:, context:)
  @device_id = event.dig('queryStringParameters', 'device_id')
  @device_ids = device_ids

  if @device_id && @device_ids.include?(@device_id)
    @records = records_for_device(@device_id)
    @latest_record = @records.max_by { |r| r['timestamp'] }
  end

  template = File.read(File.join(__dir__, 'index.html.erb'))
  body = ERB.new(template).result(binding)

  response_html(body)
end
