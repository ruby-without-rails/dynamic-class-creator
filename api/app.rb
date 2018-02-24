require 'sinatra'
require 'sinatra/contrib/all'
require 'sinatra/sequel'
require 'json'

require_relative '../lib/loadpath'
require 'requires'
require 'aliases'
require 'controllers/base_controller'
require 'controllers/mini_controller'

Dynamics = ::Module.new

# @class App
class App < Sinatra::Application
  register Sinatra::SequelExtension, Sinatra::Namespace

  include Controller::BaseController
  include Controller::MiniController

  extend Utils::ClassFactory


  configure {
    set :environment, :development

    set :raise_errors, true
    set :show_exceptions, true

    enable :cross_origin

    set :root, File.dirname(__FILE__)
    set :public_folder, Proc.new { File.join(root, '../', 'public') }
  }

  before do
    content_type :html, 'charset' => 'utf-8'
    content_type :json, 'charset' => 'utf-8'

    response.headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, AUTH_TOKEN, Auth-Token'
  end

  after {}

  error(500, 400) {
    # Log uncaught errors with Sentry, sending env variables
    # and the request body
    extra = env
    extra['REQUEST_BODY'] = @request.params
    puts extra
  }

  options('*') {
    response.headers['Allow'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, AUTH_TOKEN, Auth-Token'
    response.headers['Access-Control-Allow-Origin'] = '*'
    200
  }


  DATABASE = Models::Base::DATABASE

  ClassMap = create_classes(DATABASE, Dynamics)

  Classes = get_classes(Dynamics)

end
