require 'inflector'
require 'sequel'

module Utils::ClassFactory
  include Inflector

  # --EXIBINDO OS BANCOS DE DADOS:
  SHOW_DBS = 'SELECT datname FROM pg_database;'.freeze

  # --EXIBINDO AS TABELAS DO BANCOS DE DADOS:
  SHOW_TABLES = "SELECT table_schema as schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema;".freeze

  # --EXIBINDO AS COLUNAS DE UMA TABELA:
  SHOW_COLUMNS = "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '?';".freeze

  # --EXIBINDO AS CONSTRAINTS DAS TABELAS:
  SHOW_CONSTRAINTS = "SELECT table_name, constraint_type, constraint_name FROM information_schema.table_constraints where constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY') AND table_name = '?' ORDER BY table_name, constraint_type;".freeze

  # --EXIBINDO AS FOREIGN KEYS DAS TABELAS:
  SHOW_FOREIGN_KEYS = "SELECT tc.constraint_name , tc.table_name as source_table, kcu.column_name as source_column, ccu.table_name AS target_table, ccu.column_name AS target_column FROM information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name WHERE constraint_type = 'FOREIGN KEY' AND tc.table_name='?';".freeze

  def class_from_string(str)
    str.split('::').inject(Object) {|mod, class_name| mod.const_get(class_name)}
  end

  def get_table_constraints(connection, table_name)
    query = SHOW_CONSTRAINTS
    ConnectionFactory.execute_query(connection, query.gsub('?', table_name), false)
  end

  def get_table_foreign_keys(connection, table_name)
    query = SHOW_FOREIGN_KEYS
    ConnectionFactory.execute_query(connection, query.gsub('?', table_name), false)
  end

  def create_classes(connection, module_constant)
    table_info = scan_classes(connection)
    table_info.each {|t|

      table_name = t[:table_name]
      table_schema = t[:schema]

      next if t[:table_name].eql?('configurations')

      table_constraints = get_table_constraints(connection, table_name)
      table_fks = get_table_foreign_keys(connection, table_name)
      t[:constraints] = table_constraints.map {|tc| {type: tc[:constraint_type], name: tc[:constraint_name]}}
      t[:foreign_keys] = table_fks
      primary_key_name = t[:constraints].detect {|tc| tc[:type].eql?('PRIMARY KEY')}

      t[:columns_n_types] = get_table_columns(connection, table_name)

      fixed_name = underscore(singularize(table_name))
      dynamic_name = pascalize(fixed_name)

      classes = []

      begin
        Object.const_set(dynamic_name, Class.new(Sequel::Model) {|klass|
          set_dataset(connection[table_name.to_sym], inherited: false, require_valid_table: false)

          @db = connection
          @primary_key = primary_key_name
          @simple_table = table_name
          @db_schema = table_schema

          @table_name = table_name
          @table_schema = table_schema


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
end