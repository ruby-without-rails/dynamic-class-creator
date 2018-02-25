module Controllers
  # module BaseController
  module BaseController

    class << self
      def included(controller)
        controller.include Helpers::ApiHelper::ApiBuilder
        controller.include Helpers::ApiHelper::ApiValidation

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

        # controller.options('*') {
        #   response.headers['Allow'] = 'GET, POST, PUT, DELETE, OPTIONS'
        #   response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, AUTH_TOKEN, Auth-Token'
        #   response.headers['Access-Control-Allow-Origin'] = '*'
        #   200
        # }
      end
    end
  end
end
