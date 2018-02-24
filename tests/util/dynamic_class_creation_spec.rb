require 'codecode/common/utils'
require_relative '../../lib/loadpath'
require_relative '../../lib/models/base'
require_relative '../../lib/utils/connection_factory'
require_relative '../../lib/utils/class_factory'
require 'requires'
require 'aliases'

require 'rspec'

describe 'Dynamic Class Creator' do

  include Models
  include Utils::ClassFactory

  conn = nil

  # Database constants belong to this module namespace:
  private
  def self.load_config_file
    file = 'database.conf.yml'
    file_path = File.dirname(__FILE__) + "/../../lib/config/#{file}"
    YAML::load(File.open(file_path)) rescue fail "[Startup Info] - Arquivo de configuração [#{file}] não encontrado no diretório [#{file_path}]"
  end

  def self.load_db
    yaml = load_config_file
    Sequel.postgres(yaml)
  end


  # Database access constants:
  DB = load_db

  yaml = load_config_file

  before do
    conn = DB
  end

  it 'deve realizar a conexao e criar as classes' do
    result = ConnectionFactory.test_connection(yaml)
    expect(result).not_to be_nil

    schemas = result[:schemas]

    ConnectionFactory.close_connection(conn)

    yaml[:schemas] = schemas

    conn = ConnectionFactory.create_connection(yaml)

    table_info = scan_classes(conn)
    expect(table_info).not_to be_nil


    Dynamics = Module.new

    classes = create_classes(conn, Dynamics)
    expect(classes.size).to eq(result[:tabelas].size)

    ConnectionFactory.close_connection(conn)
  end
end
