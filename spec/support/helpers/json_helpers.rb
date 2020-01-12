# frozen_string_literal: true

module RSpecHelpers
  module JsonHelpers
    def json
      JSON.parse(response.body)
    end

    def json_struct
      JSON.parse(response.body, object_class: OpenStruct)
    end

    def symbolized_json
      if json.is_a? Array
        json.map(&:deep_symbolize_keys)
      else
        json.deep_symbolize_keys
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpecHelpers::JsonHelpers, type: :request
  config.include RSpecHelpers::JsonHelpers, type: :controller
end
