require 'yaml'
require 'json'
require 'sequel'

require_relative '../utils/discover_os'

module Models
  module Base
    # Database constants belong to this module namespace:

    private

    def self.load_config_file
      file = 'database.conf.yml'
      file_path = File.dirname(__FILE__) + "/../config/#{file}"
      begin
        YAML.safe_load(File.open(file_path))
      rescue
        raise "[Startup Info] - Arquivo de configuração [#{file}] não encontrado no diretório [#{file_path}]"
      end
    end

    def self.load_db
      yaml = load_config_file
      Sequel.postgres(yaml)
    end

    # Database access constants:
    DB = load_db

    unless Utils::DiscoverOSUtil.os?.eql?(:windows)
      if Sequel::Postgres.supports_streaming?
        # If streaming is supported, you can load the streaming support into the database:
        DB.extension(:pg_streaming)
        # If you want to enable streaming for all of a database's datasets, you can do the following:
        DB.stream_all_queries = true
        puts '[Startup Info] - Postgresql streaming foi ativado.'
      end
    end

    # @class [ModelException]
    class ModelException < StandardError
      attr_reader :status, :message, :data, :code

      def initialize(message, status = 400, code = 0, data = {})
        @status = status
        @message = message
        @data = data
        @code = code
      end

      ##
      # Convert Exception contents to a Json string. All attributes must
      # be Json serializable.
      def to_json
        JSON.generate(to_hash)
      end

      def to_hash
        {status: @status, message: @message, code: @code, data: @data}
      end

      def to_response
        [@status, to_json]
      end
    end

    class UnexpectedParamException < ModelException;
    end

    # BaseModel is just an alias to Sequel::Model class:
    class BaseModel < Sequel::Model
      @require_valid_table = false
      @forced_encoding = 'UTF-8'

      Sequel::Model.plugin :force_encoding, @forced_encoding
      Sequel.split_symbols = true
      Sequel.extension :postgres_schemata
    end

    # Class [BusinessModel] is just a signal that a business class is generic
    # and it's not binded to a specific entity or connection in database.
    class BusinessModel
      def initialize
        raise 'Essa classe não pode ser instanciada.'
      end
    end
  end
end
