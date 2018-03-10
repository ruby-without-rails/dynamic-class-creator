module Controllers
  # module BaseController
  module BaseController
    class << self
      def included(controller)
        controller.include Helpers::ApiBuilder
        controller.include Helpers::ApiValidation

        _current_dir = Dir.pwd

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
