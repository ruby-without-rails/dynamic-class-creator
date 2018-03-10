# frozen_string_literal: true

require 'sinatra'
require 'json'

require_relative '../../lib/utils/class_factory'

module Helpers
  module ApiBuilder
    include Sequel
    include Sinatra
    include Utils::ClassFactory

    CONTENT_TYPE = 'application/json;charset=utf-8'
    NOT_IMPLEMENTED_YET = {msg: 'Api not implemented yet.'}.freeze

    def make_default_json_api(options = {})
      api_instance = options[:instance]
      payload = options[:payload]
      table_name = options[:table_name]

      request_method = api_instance.env['REQUEST_METHOD']

      mapped_class, klass = verify_table(table_name)

      if payload.nil? && (%w[OPTIONS DELETE GET].index(request_method) != nil)
        begin
          api_instance.content_type CONTENT_TYPE
          status = 200
          my_yield = table_name.nil? ? yield : yield(mapped_class, klass)
          block_given? ? response = my_yield : response = NOT_IMPLEMENTED_YET
        rescue ModelException => e
          status = 400
          lambda = options[:on_error]
          response = lambda.nil? ? prepare_error_response(e) : lambda.call(e)
        end
      else
        begin
          api_instance.content_type CONTENT_TYPE
          status = 200
          body_params = prepare_payload(payload)

          if block_given?
            return_data = yield(body_params, status, mapped_class, klass)
            status = return_data[:status]
            response = return_data[:response]
          else
            response = NOT_IMPLEMENTED_YET
          end
        rescue ModelException, UniqueConstraintViolation, ConstraintViolation, CheckConstraintViolation,
            NotNullConstraintViolation, ForeignKeyConstraintViolation, MassAssignmentRestriction, ValidationFailed => e
          status = 400
          lambda = options[:on_error]
          response = lambda.nil? ? prepare_error_response(e) : lambda.call(e)
        end
      end
      [status, response.to_json.delete("\n")]
    end

    private

    def prepare_payload(raw_payload)
      raise ModelException, 'Cannot parse Payload.' if raw_payload.nil? || !raw_payload.is_a?(String) || !(raw_payload.length >= 2) || !raw_payload.match?(/{*}/)
      ::MultiJson.decode(raw_payload, symbolize_keys: true)
    end

    def verify_table(table_name)
      unless table_name.nil?
        response_type = {'Content-Type' => 'application/json'}
        halt 403, response_type, ModelException.new("Forbidden access to: #{table_name}").to_json if table_name.eql?('configurations')

        mapped_class = App::ClassMap.detect {|map| map[:table_name] == table_name}
        halt 400, response_type, ModelException.new("Mapped class not found for name: #{table_name}").to_json unless mapped_class

        klass = class_from_string(mapped_class[:class_name])
        halt 400, response_type, ModelException.new("Class not found for name: #{mapped_class[:class_name]}").to_json unless klass
        [mapped_class, klass]
      end
    end

    def prepare_error_response(exception)
      exception.is_a?(ModelException) ? message = exception.message : message = exception.message[/DETAIL:(.*)/] || exception.to_s
      {error: {msg: message, status_code: 400}}
    end
  end

  module ApiValidation
    # @param [Hash] body_params request body params
    # @param [Array] expected_params array of symbols of expected params
    def validate_params(body_params, expected_params)
      expected_params.each {|s| raise ModelException, "Parameter #{s} not found. Invalid payload." unless body_params.key?(s)}
    end
  end
end
