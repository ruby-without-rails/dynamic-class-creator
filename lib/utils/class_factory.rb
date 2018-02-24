module Utils
  module ClassFactory
    include Models::Base

    # --EXIBINDO OS BANCOS DE DADOS:
    # SELECT datname FROM pg_database;
    SHOW_DBS = 'SELECT datname FROM pg_database;'.freeze

    # --EXIBINDO AS TABELAS DO BANCOS DE DADOS:
    # SELECT table_schema as schema, table_name as table FROM information_schema.tables
    # WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema;
    SHOW_TABLES = "SELECT table_schema as schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema;".freeze

    # --EXIBINDO AS COLUNAS DE UMA TABELA:
    # SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '?';
    SHOW_COLUMNS = "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '?';".freeze

    # --EXIBINDO AS CONSTRAINTS DAS TABELAS:
    # select table_name, constraint_type, constraint_name
    # from information_schema.table_constraints where constraint_type in ('PRIMARY KEY', 'FOREIGN KEY') order by table_name, constraint_type;
    SHOW_CONSTRAINTS = "SELECT table_name, constraint_type, constraint_name FROM information_schema.table_constraints where constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY') AND table_name = '?' ORDER BY table_name, constraint_type;".freeze

    def class_from_string(str)
      str.split('::').inject(Object) {|mod, class_name| mod.const_get(class_name)}
    end

    def get_table_constraints(connection, table_name)
      query = SHOW_CONSTRAINTS
      ConnectionFactory.execute_query(connection, query.gsub('?', table_name), false)
    end

    def create_classes(connection, module_constant, name_convention = false)
      table_info = scan_classes(connection)
      table_info.each {|t|

        table_name = t[:table_name]
        table_schema = t[:schema]

        table_constraints = get_table_constraints(connection, table_name)
        t[:constraints] = table_constraints.map {|tc| {type: tc[:constraint_type], name: tc[:constraint_name]}}
        primary_key_name = t[:constraints].detect {|tc| tc[:type].eql?('PRIMARY KEY')}

        t[:columns_n_types] = get_table_columns(connection, table_name)

        dynamic_name = snake_case_to_camel_case_name(table_name)
        classes = []

        begin
          Object.const_set(dynamic_name, Class.new(BaseModel) {|klass|
            @db = connection

            unless name_convention
              @require_valid_table = false
              @primary_key = primary_key_name
              @simple_table = table_name
              @db_schema = table_schema

              @table_name = table_name
              @table_schema = table_schema
              @fast_instance_delete_sql = ''
              @fast_pk_lookup_sql = ''

              set_dataset(connection[table_name.to_sym])
            end

            class << self
              define_method('find_by_id') {|value| self[value]}
              define_method('delete_by_id') {|value| self[value].destroy}
            end

            module_constant.const_set(dynamic_name, klass)

            classes << klass

            t[:class_name] = klass.name
            puts "Creating class: #{t[:class_name]}"
          })
        ensure
          connection.disconnect
        end

        classes
      }
    end

    def get_table_columns(connection, table_name)
      query = SHOW_COLUMNS
      ConnectionFactory.execute_query(connection, query.gsub('?', table_name), false)
    end

    def get_classes(module_instance)
      module_instance.constants.select {|c| module_instance.const_get(c).is_a? Class}
    end

    def scan_classes(connection)
      ConnectionFactory.execute_query(connection, SHOW_TABLES, false)
    end

    private

    def scan_fields(connection, table_name)
      query = SHOW_COLUMNS.gsub('?', table_name)
      ConnectionFactory.execute_query(connection, query, false)
    end

    def snake_case_to_camel_case_name(string)
      string = string.tr('_', ' ').split.map.with_index {|x, i| i.zero? ? x : x.capitalize}.join
      string[0] = string[0].upcase
      string
    end
  end
end