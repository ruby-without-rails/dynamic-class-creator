require 'sinatra'
require 'sinatra/sequel'
require 'json'

require_relative '../lib/exceptions/unexpected_param_exception'
require_relative '../lib/../lib/models/base'

# @class App
class App < Sinatra::Base
  register Sinatra::SequelExtension
  include CodeCode::Exception

  configure {
    set :environment, :development
    set :bind, '0.0.0.0'
    set :port, 9494

    set :raise_errors, true
    set :show_exceptions, true

    DB = CodeCode::Models::Base::DB
  }

  before {
    content_type :html, 'charset' => 'utf-8'
    content_type :json, 'charset' => 'utf-8'
  }

  get('/') { {msg: 'Welcome To Dynamic Ruby Class Creator'}.to_json}

  get('/hello') { 'Hello Guest' }

  get('/hello/') { redirect '/hello' }

  get('/tables'){

  }

  run!
end