module CodeCode
  module Utils
    module ClassFactory

      # --EXIBINDO OS BANCOS DE DADOS:
      # SELECT datname FROM pg_database;
      SHOW_DBS = 'SELECT datname FROM pg_database;'.freeze

      # --EXIBINDO AS TABELAS DO BANCOS DE DADOS:
      # SELECT table_schema as schema, table_name as table FROM information_schema.tables
      # WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema;
      SHOW_TABLES = "SELECT table_schema as schema, table_name as table FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema;".freeze

      # --EXIBINDO AS COLUNAS DE UMA TABELA:
      # SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '?';
      SHOW_COLUMNS = "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '?';".freeze

      def create_classes(connection, module_constant)
        table_info = scan_classes(connection)
        table_info.each do |t|
          table_name = t[:table]
          table_schema = t[:schema]


          dynamic_name = snake_case_to_camel_case_name(table_name)
          classes = []

          begin
            Object.const_set(dynamic_name, Class.new(BaseModel){|klass|
              @db = connection
              @require_valid_table = false
              @primary_key = nil
              @simple_table = table_name
              @db_schema = table_schema

              @table_name = table_name
              @table_schema = table_schema
              @fast_instance_delete_sql = ''
              @fast_pk_lookup_sql = ''


              set_dataset(connection[table_name.to_sym])

              class << self
                define_method('find_by_id'){ |value| self[value] }
                alias_method :obter_por_id, :find_by_id
              end

              module_constant.const_set(dynamic_name, klass)

              classes << klass
            })
            classes.each{|klass| p "#{klass.name}" }
          ensure
            connection.disconnect
          end

          classes
        end
      end

      def scan_classes(connection)
        ConnectionFactory.executar_query_sql(connection, SHOW_TABLES, false)
      end

      private
      def snake_case_to_camel_case_name(string)
        string = string.tr('_', ' ').split.map.with_index { |x, i| i.zero? ? x : x.capitalize }.join
        string[0] = string[0].upcase
        string
      end
    end
  end
end
