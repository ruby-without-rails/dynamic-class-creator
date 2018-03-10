module Controllers
  module ConfigurationCtrl
    class << self
      def included(controller)

        controller.namespace('/api') {|c|
          c.get('/configuration/version') {
            make_default_json_api(instance: self) {
              Configuration.app_version
            }
          }

          c.get('/configuration') {
            make_default_json_api(instance: self) {
              Configuration.list_configurations
            }
          }

          c.get('/routes') {
            make_default_json_api(instance: self) {
              Configuration.list_apis(c)
            }
          }
        }
      end
    end
  end
end
