require 'requires'

include Models::Base

module Utils
  class ConnectionFactory
    class << self
      def create_connection(connection_params)
        connection_params = {
          host: connection_params[:host] || connection_params['host'],
          user: connection_params[:user] || connection_params['user'],
          password: connection_params[:password] || connection_params['password'],
          database: connection_params[:database] || connection_params['database'],
          port: connection_params[:port] || connection_params['port'] || 5432
        }

        connection_params.each { |k, v| raise ModelException, "Valor nulo no parametro #{k}" if v.nil? }

        if connection_params[:schemas]
          schemas = ['public']
          schemas << connection_params[:schemas]
          schemas.flatten!
          schemas.uniq!
        end

        if schemas
          Sequel.connect(connection_params, adapter: 'postgres', search_path: schemas)
          # Sequel.postgres(connection_params, search_path: schemas)
        else
          Sequel.postgres(connection_params)
        end
      end

      def close_connection(conexao)
        conexao.disconnect if conexao
      end

      def test_connection(parametros_conexao)
        all_tables_query = '(SELECT * FROM information_schema.tables);'.freeze
        all_schemas_query = '(SELECT schema_name FROM information_schema.schemata);'.freeze

        begin
          db = create_connection(parametros_conexao)
        rescue DatabaseError => e
          message = e.message
          return { sucesso: false, msg: message }
        ensure
          db.disconnect if db
        end

        schemas = db[all_schemas_query].all.collect { |s| s[:schema_name] unless s[:schema_name].include?('pg_') }.compact!
        schemas = schemas.keep_if { |s| !s.eql?('information_schema') }
        tables = db[all_tables_query].all.collect { |t| t[:table_name] if t[:table_type].eql?('BASE TABLE') && !t[:table_name].include?('pg_') && !t[:table_name].include?('sql_') }.compact!

        { sucesso: true, msg: 'Conexão realizada com sucesso!', tabelas: tables, schemas: schemas }
      end

      def execute_query(connection, query, auto_close_connection = true)
        raise ModelException, 'Conexão inválida.' unless connection
        raise ModelException, 'Query inválida.' unless query || query.blank?

        begin
          connection[query].all
        ensure
          connection.disconnect if connection && auto_close_connection
        end
      end
    end
  end
end
