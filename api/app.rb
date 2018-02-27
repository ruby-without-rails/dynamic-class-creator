require_relative '../lib/loadpath'
require 'models/base'

require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/contrib/all'
require 'sinatra/sequel'

Dynamics = ::Module.new

# @class App
class App < Sinatra::Application
  register Sinatra::SequelExtension, Sinatra::Namespace, Sinatra::CrossOrigin
  extend Models

  DATABASE = load_db

  require 'requires'
  require 'aliases'

  %w[controllers].each {|folder| Dir["#{Dir.pwd}/lib/#{folder}/*.rb"].each {|file| require file}}

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
    set :public_folder, File.join(root, '../', 'public')

    set :allow_origin, :any
    set :allow_methods, %i[get post put delete options]
    set :allow_credentials, true
    set :max_age, '1728000'
    set :expose_headers, %w[Authorization Content-Type Accept X-User-Email X-Auth-Token AUTH_TOKEN Auth-Token]
  }

  before {
    content_type :html, 'charset' => 'utf-8'
    content_type :json, 'charset' => 'utf-8'
  }

  after {}

  error(500, 400) {
    extra = env
    extra['REQUEST_BODY'] = @request.body.read
    warn extra
  }

  helpers {
    ClassMap = create_classes(DATABASE, Dynamics)
    Classes = get_classes(Dynamics)

    def sample_method
      'sample method'
    end
  }

end
