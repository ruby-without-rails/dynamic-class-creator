require 'sinatra'
require 'sinatra/sequel'
require 'json'

require_relative '../lib/loadpath'
require_relative '../lib/models/base'
require_relative '../lib/requires'
require_relative '../lib/aliases'
require_relative '../lib/exceptions/unexpected_param_exception'
require_relative '../lib/controllers/base_controller'
require_relative '../lib/controllers/mini_controller'


# @class App
class App < Sinatra::Application
  register Sinatra::SequelExtension

  include Controller::BaseController
  extend Controller::MiniController

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

  after {

  }

  run!
end