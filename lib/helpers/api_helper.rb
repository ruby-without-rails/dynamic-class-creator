require 'sinatra'
require 'json'
require_relative '../models/base'

module Helpers
  module ApiHelper
    module ApiBuilder
      include Models::Base
      include Sequel
      include Sinatra
      include CodeCode::Common::Utils::Hash

      CONTENT_TYPE = 'application/json;charset=utf-8'.freeze

      def make_default_json_api(api_instance, payload = {})
        request_method = api_instance.env['REQUEST_METHOD']

        if payload.empty? && (request_method.eql?('GET') || request_method.eql?('DELETE') || request_method.eql?('OPTIONS'))

          begin
            api_instance.content_type CONTENT_TYPE
            status = 200
            block_given? ? response = yield : response = {msg: 'Api ainda não implementada.'}
          rescue ModelException => e
            status = 400
            response = {error: {msg: e.message, status_code: status}}
          end
          [status, response.to_json.delete("\n")]
        else

          begin
            api_instance.content_type CONTENT_TYPE
            body_params = !payload.empty? && !payload.is_a?(IndifferentHash) && payload.length >= 2 && payload.match?(/\{*}/) ? JSON.parse(payload) : payload

            if body_params.is_a?(Hash)
              symbolize_keys!(body_params)
            else
              raise ModelException.new 'Cannot parse Payload.'
            end

            status = 200

            if block_given?
              return_data = yield(body_params, status)
              status = return_data[:status]
              response = return_data[:response]
            else
              response = {msg: 'Api não implementada.'}
            end
          rescue ModelException => e
            status = 400
            response = {error: {msg: e.message, status_code: status}}
          rescue ConstraintViolation, UniqueConstraintViolation, CheckConstraintViolation,
              NotNullConstraintViolation, ForeignKeyConstraintViolation => e
            message = e.message[/DETAIL:(.*)/]
            status = 400
            response = {error: {msg: message, status_code: status}}
          end
          [status, response.to_json.delete("\n")]
        end
      end
    end

    module ApiValidation
      include Models::Base

      def validate_params(body_params, symbols)
        symbols.each {|s| raise ModelException, "Parâmetro #{s} não encontrado. Payload incorreto." unless body_params.key?(s)}
      end
    end
  end
end
