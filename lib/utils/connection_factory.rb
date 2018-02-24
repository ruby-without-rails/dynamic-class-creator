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

        connection_params.each { |k, v| raise ModelException, "Null value at parameter #{k}" if v.nil? }

        if connection_params[:schemas]
          schemas = ['public']
          schemas << connection_params[:schemas]
          schemas.flatten!
          schemas.uniq!
        end

        if schemas
          Sequel.connect(connection_params, adapter: 'postgres', search_path: schemas)
        else
          Sequel.postgres(connection_params)
        end
      end

      def close_connection(connection)
        connection.disconnect if connection
      end

      def test_connection(connection_params)
        all_tables_query = 'SELECT * FROM information_schema.tables'.freeze
        all_schemas_query = 'SELECT schema_name FROM information_schema.schemata;'.freeze

        begin
          db = create_connection(connection_params)
        rescue DatabaseError => e
          message = e.message
          return { success: false, msg: message }
        ensure
          db.disconnect if db
        end

        schemas = db[all_schemas_query].all.collect { |s| s[:schema_name] unless s[:schema_name].include?('pg_') }.compact!
        schemas = schemas.keep_if { |s| !s.eql?('information_schema') }
        tables = db[all_tables_query].all.collect { |t| t[:table_name] if t[:table_type].eql?('BASE TABLE') && !t[:table_name].include?('pg_') && !t[:table_name].include?('sql_') }.compact!

        { success: true, msg: 'Connection successful!', tabelas: tables, schemas: schemas }
      end

      def execute_query(connection, query, auto_close_connection = true)
        raise ModelException, 'Invalid connection.' unless connection
        raise ModelException, 'Invalid query.' unless query || query.blank?

        begin
          connection[query].all
        ensure
          connection.disconnect if connection && auto_close_connection
        end
      end
    end
  end
end
