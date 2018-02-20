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
  include CodeCode::Utils::ClassFactory

  DB = CodeCode::Models::Base::DB

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


  get('/') {{msg: 'Welcome To Dynamic Ruby Class Creator'}}

  options('/tables') {{tables: ClassMap}.to_json}

  get('/table/:table_name') {|table_name|
    mapped_class = ClassMap.detect {|map| map[:table_name] == table_name}
    raise ModelException.new "Mapped class not found for name: #{table_name}" unless mapped_class

    the_class = class_from_string(mapped_class[:class_name])
    raise ModelException.new "Class not found for name: #{mapped_class[:class_name]}" unless the_class

    object = the_class.all.map(&:values)
    {"#{mapped_class[:table_name]}": object}.to_json
  }

  get('/table/:table_name/:id') {|table_name, id|

    mapped_class = ClassMap.detect {|map| map[:table_name] == table_name}
    raise ModelException.new "Mapped class not found for name: #{table_name}" unless mapped_class

    the_class = class_from_string(mapped_class[:class_name])
    raise ModelException.new "Class not found for name: #{mapped_class[:class_name]}" unless the_class

    object = the_class.obter_por_id(id)&.values
    {"#{mapped_class[:table_name]}": object}.to_json
  }

  post('') {
    mapped_class = ClassMap.detect {|map| map[:table_name] == table_name}
    raise ModelException.new "Mapped class not found for name: #{table_name}" unless mapped_class

    the_class = class_from_string(mapped_class[:class_name])
    raise ModelException.new "Class not found for name: #{mapped_class[:class_name]}" unless the_class


  }

  run!
end