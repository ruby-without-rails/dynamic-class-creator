#
# Base requirement
#
require 'requires'
require 'base_controller'

module Controllers
  module ConfigurationCtrl
    class << self
      def extended(controller)
        controller.include Utils::ApiHelper

        controller.namespace('/api') {|c|
          c.get('/configuration/version') {
            make_default_json_api(self) {
              Configuration.get_version
            }
          }

          c.get('/configuration') {
            make_default_json_api(self) {
              Configuration.list_configurations
            }
          }

          c.get('/routes') {
            make_default_json_api(self) {
              Configuration.list_apis(c)
            }
          }
        }
      end
    end
  end
end
