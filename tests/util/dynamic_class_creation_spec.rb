require_relative '../../lib/loadpath'
require_relative '../../lib/models/base'
require_relative '../../lib/utils/connection_factory'
require_relative '../../lib/utils/class_factory'
require 'requires'

require 'rspec'

describe 'Dynamic Class Creator' do

  include Models
  include Utils::ClassFactory

  conn = nil
  yaml = nil

  before do
    conn = load_db
    require '../../lib/models/configuration'
    require 'aliases'
    yaml = load_config_file
  end

  it 'deve realizar a conexao e criar as classes dinamicamente' do
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
