require 'sinatra'
require 'sinatra/sequel'
require 'json'

require_relative '../lib/loadpath'
require_relative '../lib/models/base'
require_relative '../lib/requires'
require_relative '../lib/aliases'
require_relative '../lib/exceptions/unexpected_param_exception'
require_relative '../lib/utils/class_factory'

# @class App
class App < Sinatra::Base
  register Sinatra::SequelExtension
  extend CodeCode::Utils::ClassFactory

  DB = CodeCode::Models::Base::DB

  Dynamics = Module.new

  Classes = create_classes(DB, Dynamics)

  configure {
    set :environment, :development
    set :bind, '0.0.0.0'
    set :port, 9494

    set :raise_errors, true
    set :show_exceptions, true
  }

  before {
    content_type :html, 'charset' => 'utf-8'
    content_type :json, 'charset' => 'utf-8'
  }

  get('/') {{msg: 'Welcome To Dynamic Ruby Class Creator'}.to_json}

  get('/tables') {{tables: Classes}.to_json}

  run!
end