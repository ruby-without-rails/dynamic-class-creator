require 'codecode/common/utils'
require_relative '../utils/class_factory'


Dynamics = ::Module.new

module Controller
  # module BaseController
  module BaseController
    extend Utils::ClassFactory
    include Utils::ClassFactory

    DB = Models::Base::DB

    ClassMap = create_classes(DB, Dynamics)

    Classes = get_classes(Dynamics)

    class << self
      def included(controller)
        controller.include Helpers::ApiHelper::ApiBuilder
        controller.include Helpers::ApiHelper::ApiValidation
      end
    end
  end
end
