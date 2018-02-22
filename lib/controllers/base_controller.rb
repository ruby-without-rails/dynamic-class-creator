require 'codecode/common/utils'
require_relative '../utils/class_factory'


Dynamics = ::Module.new

module Controller
  # module BaseController
  module BaseController
    extend Utils::ClassFactory
    include Utils::ClassFactory

    DATABASE = Models::Base::DATABASE

    ClassMap = create_classes(DATABASE, Dynamics)

    Classes = get_classes(Dynamics)

    class << self
      def included(controller)
        controller.include Helpers::ApiHelper::ApiBuilder
        controller.include Helpers::ApiHelper::ApiValidation

        controller.get('/') {
          content_type 'text/html; charset=utf-8'
          file_path = File.join(settings.public_folder, 'index.html')
          if File.exist?(file_path) && File.readable?(file_path)
            send_file file_path
          else
            'File not Found!'
          end
        }
      end
    end
  end
end
