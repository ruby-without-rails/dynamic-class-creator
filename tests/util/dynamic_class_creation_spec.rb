require '../../lib/loadpath'
require '../../lib/models/base'
require '../../lib/requires'
require '../../lib/aliases'

require 'rspec'

describe 'Dynamic Class Creator' do

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

    case ENV['RACK_ENV']
      when 'HMG' then
        fail 'Not implemented yet!'
      when 'PROD' then
        fail 'Not implemented yet!'
      else
        Sequel.postgres(yaml)
    end
  end


  # Database access constants:
  DB = load_db

  yaml = load_config_file

  before do
    # conn = ConnectionFactory.criar_conexao(yaml)
    conn = DB
  end

  it 'deve realizar a conexao e criar as classes' do
    result = ConnectionFactory.testar_conexao(yaml)
    expect(result).not_to be_nil

    schemas = result[:schemas]

    ConnectionFactory.fechar_conexao(conn)

    yaml[:schemas] = schemas

    conn = ConnectionFactory.criar_conexao(yaml)

    table_info = scan_classes(conn)
    expect(table_info).not_to be_nil


    Dynamics = Module.new

    classes = create_classes(conn, Dynamics)
    expect(classes.size).to eq(result[:tabelas].size)

    ConnectionFactory.fechar_conexao(conn)
  end
end
