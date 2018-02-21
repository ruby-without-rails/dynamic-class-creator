require 'sinatra'
require 'sinatra/sequel'
require 'json'

require_relative '../lib/loadpath'
require_relative '../lib/models/base'
require_relative '../lib/requires'
require_relative '../lib/aliases'
require_relative '../lib/exceptions/unexpected_param_exception'
require_relative '../lib/utils/class_factory'
require_relative '../lib/controllers/base_controller'
require_relative '../lib/controllers/mini_controller'
# @class App
class App < Sinatra::Application
  register Sinatra::SequelExtension
  extend Utils::ClassFactory
  include Utils::ClassFactory
  include Controller::BaseController
  extend Controller::MiniController

  DB = Models::Base::DB

  Dynamics = Module.new

  ClassMap = create_classes(DB, Dynamics)

  Classes = get_classes(Dynamics)

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