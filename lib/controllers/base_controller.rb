require 'codecode/common/utils'


module Controller
  # module BaseController
  module BaseController
    class << self
      def included(controller)
        controller.include Helpers::ApiHelper::ApiBuilder
        controller.include Helpers::ApiHelper::ApiValidation
      end
    end
  end
end
