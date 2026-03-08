# frozen_string_literal: true

require 'minitest/autorun'
require 'mocha/minitest'
require 'json'
require 'aws-sdk-dynamodb'
require_relative '../src/dashboard/app'

class TestApp < Minitest::Test
  def setup
    ENV['SENSOR_READINGS_TABLE'] = 'test_table'
    # Mock Aws::DynamoDB::Table.new to return a mock object
    @mock_table = mock('Aws::DynamoDB::Table')
    Aws::DynamoDB::Table.stubs(:new).returns(@mock_table)

    # Stub File.read for the ERB template
    File.stubs(:read).with(regexp_matches(/index\.html\.erb$/)).returns(<<~HTML)
      <html>
        <body>
          <div id="device_ids">
            <% if @device_ids %>
              <% @device_ids.each do |id| %>
                <p><%= id %></p>
              <% end %>
            <% end %>
          </div>
          <div id="records">
            <% if @records %>
              <% @records.each do |record| %>
                <p><%= record['device_id'] %>: <%= record['timestamp'] %></p>
              <% end %>
            <% end %>
          </div>
          <div id="latest_record">
            <% if @latest_record %>
              <p>Latest: <%= @latest_record['device_id'] %>: <%= @latest_record['timestamp'] %></p>
            <% end %>
          </div>
        </body>
      </html>
    HTML
  end

  def test_device_ids_returns_unique_ids
    @mock_table.expects(:scan).with(
      projection_expression: :device_id
    ).returns(stub(items: [
                     { 'device_id' => 'device1', 'timestamp' => 1 },
                     { 'device_id' => 'device2', 'timestamp' => 2 },
                     { 'device_id' => 'device1', 'timestamp' => 3 }
                   ]))

    assert_equal %w[device1 device2], device_ids
  end

  def test_records_for_device_returns_correct_records
    device_id = 'device1'
    @mock_table.expects(:query).with(
      key_condition_expression: 'device_id = :device_id',
      expression_attribute_values: { ':device_id' => device_id }
    ).returns(stub(items: [
                     { 'device_id' => 'device1', 'timestamp' => 10 },
                     { 'device_id' => 'device1', 'timestamp' => 20 }
                   ]))

    assert_equal [
      { 'device_id' => 'device1', 'timestamp' => 10 },
      { 'device_id' => 'device1', 'timestamp' => 20 }
    ], records_for_device(device_id)
  end

  def test_handler_without_device_id_displays_all_device_ids
    # Stub device_ids and records_for_device calls within the handler's context
    stubs(:device_ids).returns(%w[deviceA deviceB])
    stubs(:records_for_device).returns([]) # Should not be called

    response = handler(event: {}, context: nil)

    assert_equal 200, response[:statusCode]
    assert_includes response[:body], '<p>deviceA</p>'
    assert_includes response[:body], '<p>deviceB</p>'
  end

  def test_handler_with_valid_device_id_displays_device_records
    expected_records = [
      { 'device_id' => 'deviceX', 'timestamp' => 100 },
      { 'device_id' => 'deviceX', 'timestamp' => 200 }
    ]
    stubs(:device_ids).returns(%w[deviceX deviceY])
    stubs(:records_for_device).with('deviceX').returns(expected_records)

    event = { 'queryStringParameters' => { 'device_id' => 'deviceX' } }
    response = handler(event: event, context: nil)

    assert_equal 200, response[:statusCode]
    assert_includes response[:body], '<p>deviceX</p>' # device_id in list
    assert_includes response[:body], '<p>deviceX: 100</p>'
    assert_includes response[:body], '<p>deviceX: 200</p>'
    assert_includes response[:body], '<p>Latest: deviceX: 200</p>'
  end

  def test_handler_with_invalid_device_id
    stubs(:device_ids).returns(%w[deviceA deviceB])
    stubs(:records_for_device).returns([]) # Should not be called for invalid ID

    event = { 'queryStringParameters' => { 'device_id' => 'unknown_device' } }
    response = handler(event: event, context: nil)

    assert_equal 200, response[:statusCode]
    assert_includes response[:body], '<p>deviceA</p>'
    assert_includes response[:body], '<p>deviceB</p>'
    refute_includes response[:body], 'unknown_device'
  end
end
