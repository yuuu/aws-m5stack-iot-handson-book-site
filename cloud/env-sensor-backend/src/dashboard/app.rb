# frozen_string_literal: true

require 'erb'
require 'json'

def handler(event:, context:)
  @temperature = 25.1
  @humidity = 45.5
  @pressure = 1012.8

  template = File.read(File.join(__dir__, 'index.html.erb'))
  body = ERB.new(template).result(binding)

  {
    statusCode: 200,
    headers: { 'Content-Type': 'text/html' },
    body: body
  }
end
