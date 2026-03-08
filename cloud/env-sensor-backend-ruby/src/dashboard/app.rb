# frozen_string_literal: true

require 'erb'
require 'aws-sdk-dynamodb'

def dynamodb_table
  table_name = ENV.fetch('SENSOR_READINGS_TABLE', '')
  Aws::DynamoDB::Table.new(table_name)
end

def device_ids
  res = dynamodb_table.scan(projection_expression: :device_id)
  res.items.map { it['device_id'] }.uniq
end

def records_for_device(device_id)
  res = dynamodb_table.query(
    key_condition_expression: 'device_id = :device_id',
    expression_attribute_values: { ':device_id' => device_id },
  )
  res.items
end

def response_html
  template = File.read(File.join(__dir__, 'index.html.erb'))
  body = ERB.new(template).result(binding)
  {
    statusCode: 200,
    headers: { 'Content-Type': 'text/html' },
    body:
  }
end

def handler(event:, context:)
  @device_ids = device_ids
  @device_id = event.dig('queryStringParameters', 'device_id') || @device_ids.first

  if @device_id && @device_ids.include?(@device_id)
    @records = records_for_device(@device_id)
    @latest_record = @records.max_by { |r| r['timestamp'] }
  end
  @records ||= []

  response_html
end
