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
  }

  after {}

  error(500, 400) {
    extra = env
    extra['REQUEST_BODY'] = @request.body.read
    warn extra
  }

  helpers {
    DATABASE = Models::DATABASE

    ClassMap = create_classes(DATABASE, Dynamics)

    Classes = get_classes(Dynamics)

    def sample_method
      'sample method'
    end
  }

end
