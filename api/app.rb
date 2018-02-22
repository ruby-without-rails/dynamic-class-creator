require 'sinatra'
require 'sinatra/contrib/all'
require 'sinatra/sequel'
require 'json'

require_relative '../lib/loadpath'
require_relative '../lib/models/base'
require_relative '../lib/requires'
require_relative '../lib/aliases'
require_relative '../lib/exceptions/model_exception'
require_relative '../lib/exceptions/unexpected_param_exception'
require_relative '../lib/controllers/base_controller'
require_relative '../lib/controllers/mini_controller'

# @class App
class App < Sinatra::Application
  register Sinatra::SequelExtension, Sinatra::Namespace

  include Controller::BaseController
  extend Controller::MiniController

  configure {
    set :environment, :development
    set :bind, '0.0.0.0'
    set :port, 9494

    set :raise_errors, true
    set :show_exceptions, true

    enable :cross_origin
    enable :reloader

    set :root, File.dirname(__FILE__)
    set :public_folder, Proc.new { File.join(root, '../', 'public') }
  }

  before do
    content_type :html, 'charset' => 'utf-8'
    content_type :json, 'charset' => 'utf-8'

    response.headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, KUADRO_AUTH_TOKEN, Kuadro-Auth-Token'
  end

  after {}

  error(500, 400) {
    # Log uncaught errors with Sentry, sending env variables
    # and the request body
    extra = env
    extra['REQUEST_BODY'] = request.body
    puts extra
  }

  options('*') {
    response.headers['Allow'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, KUADRO_AUTH_TOKEN, Kuadro-Auth-Token'
    response.headers['Access-Control-Allow-Origin'] = '*'
    200
  }

  run!
end
