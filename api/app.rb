require_relative '../lib/loadpath'
require 'models/base'

require 'yaml'
require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/contrib/all'
require 'sinatra/sequel'

Dynamics = ::Module.new

# @class App
class App < Sinatra::Application
  register Sinatra::SequelExtension, Sinatra::Namespace, Sinatra::CrossOrigin, Sinatra::ConfigFile
  config_file File.join("#{Dir.pwd}/lib/config/rack.conf.yml")
  extend Models

  DATASOURCE = load_db
  CLASS_FACTORY_OPTIONS = YAML.safe_load(File.open("#{Dir.pwd}/lib/config/class_factory.conf.yml"))

  require 'requires'
  require 'aliases'

  %w[controllers].each {|folder| Dir["#{Dir.pwd}/lib/#{folder}/*.rb"].each { |file| require file}}

  Controllers.constants.each{|ctrl_sym|
    module_name = Kernel.const_get('Controllers::?'.gsub('?', ctrl_sym.to_s))
    include module_name
  }

  extend Utils::ClassFactory

  configure {
    set :environment, settings.environment
    set server: 'webrick'
    set :raise_errors, settings.raise_errors
    set :show_exceptions, settings.show_exceptions
    set :root, File.dirname(__FILE__)
    set :public_folder, File.join(root, '../', 'public')
  }

  configure(:development) {
    enable :cross_origin
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
    def sample_method
      'sample method'
    end
  }

  ClassMap = create_classes(DATASOURCE, Dynamics, CLASS_FACTORY_OPTIONS['name_conflicts'])
  Classes = get_classes(Dynamics)

  require 'extensions/models/dynamics_common'
  include Extensions::DynamicsCommon
end
