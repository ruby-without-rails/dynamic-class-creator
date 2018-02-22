require 'yaml'
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

    # BaseModel is just an alias to Sequel::Model class:
    class BaseModel < Sequel::Model
      @require_valid_table = false
      @forced_encoding = 'UTF-8'

      Sequel::Model.plugin :force_encoding, @forced_encoding
      Sequel.split_symbols = true
      Sequel.extension :postgres_schemata
    end
  end
end
