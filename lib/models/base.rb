require 'yaml'
require 'sequel'

require_relative '../utils/discover_os'

module Models
    # Database constants belong to this module namespace:

    private

    def self.load_config_file
      file = 'database.conf.yml'
      file_path = File.dirname(__FILE__) + "/../config/#{file}"
      begin
        YAML.safe_load(File.open(file_path))
      rescue
        raise "[Startup Info] - Config file [#{file}] not found in this directory [#{file_path}]"
      end
    end

    def self.load_db
      yaml = load_config_file
      Sequel.postgres(yaml)
    end

    # Database access constants:
    DATABASE = load_db

    unless Utils::DiscoverOS.os?.eql?(:windows)
      if Sequel::Postgres.supports_streaming?
        # If streaming is supported, you can load the streaming support into the database:
        DATABASE.extension(:pg_streaming)
        # If you want to enable streaming for all of a database's datasets, you can do the following:
        DATABASE.stream_all_queries = true
        puts '[Startup Info] - Postgresql streaming was activated.'
      end
    end
end
