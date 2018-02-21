require 'requires'

include Models::Base

module Utils

  class ConnectionFactory
    class << self
      def criar_conexao(parametros_conexao)
        connection_params = {
            host: parametros_conexao[:host] || parametros_conexao['host'],
            user: parametros_conexao[:user] || parametros_conexao['user'],
            password: parametros_conexao[:password] || parametros_conexao['password'],
            database: parametros_conexao[:database] || parametros_conexao['database'],
            port: parametros_conexao[:port] || parametros_conexao['port'] || 5432
        }

        connection_params.each {|k, v| raise ModelException.new "Valor nulo no parametro #{k}" if v.nil?}

        if parametros_conexao[:schemas]
          schemas = ['public']
          schemas << parametros_conexao[:schemas]
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

      def fechar_conexao(conexao)
        conexao.disconnect if conexao
      end

      def testar_conexao(parametros_conexao)
        all_tables_query = '(SELECT * FROM information_schema.tables);'.freeze
        all_schemas_query = '(SELECT schema_name FROM information_schema.schemata);'.freeze

        begin
          db = criar_conexao(parametros_conexao)
        rescue DatabaseError => e
          message = e.message
          return {sucesso: false, msg: message}
        ensure
          db.disconnect if db
        end

        schemas = db[all_schemas_query].all.collect {|s| s[:schema_name] unless s[:schema_name].include?('pg_')}.compact!
        schemas = schemas.keep_if {|s| !s.eql?('information_schema')}
        tables = db[all_tables_query].all.collect {|t| t[:table_name] if t[:table_type].eql?('BASE TABLE') && !t[:table_name].include?('pg_') && !t[:table_name].include?('sql_')}.compact!

        {sucesso: true, msg: 'Conexão realizada com sucesso!', tabelas: tables, schemas: schemas}
      end

      def executar_query_sql(connection, query, auto_close_connection = true)
        raise ModelException.new 'Conexão inválida.' unless connection
        raise ModelException.new 'Query inválida.' unless query or query.blank?

        begin
          connection[query].all
        ensure
          connection.disconnect if connection and auto_close_connection
        end
      end
    end
  end
end


