require 'sinatra'
require 'sinatra/contrib/all'
require 'sinatra/sequel'

require_relative '../lib/loadpath'
require 'requires'
require 'aliases'

current_dir = Dir.pwd
%w[controllers].each {|folder| Dir["#{current_dir}/lib/#{folder}/*.rb"].each {|file| require file}}

Dynamics = ::Module.new

# @class App
class App < Sinatra::Application
  register Sinatra::SequelExtension, Sinatra::Namespace


  Controllers.constants.each{|controller|
    module_name = Kernel.const_get('Controllers::?'.gsub('?', controller.to_s))
    include module_name
  }

  extend Utils::ClassFactory


  configure {
    set :environment, :development
    set server: 'webrick'

    set :raise_errors, true
    set :show_exceptions, true

    enable :cross_origin

    set :root, File.dirname(__FILE__)
    set :public_folder, Proc.new { File.join(root, '../', 'public') }
  }

  before {
    content_type :html, 'charset' => 'utf-8'
    content_type :json, 'charset' => 'utf-8'

    # response.headers['Access-Control-Allow-Origin'] = '*'
    # headers['Access-Control-Allow-Origin'] = '*'
    # headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    # headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, AUTH_TOKEN, Auth-Token'
  }

  after {}

  error(500, 400) {
    # Log uncaught errors with Sentry, sending env variables
    # and the request body
    extra = env
    extra['REQUEST_BODY'] = @request.params
    puts extra
  }

  helpers {
    def parsed_body
      ::MultiJson.decode(@request.body)
    end
  }


  DATABASE = Models::Base::DATABASE

  ClassMap = create_classes(DATABASE, Dynamics)

  Classes = get_classes(Dynamics)

end
