require 'singleton'
require 'codecode/common/utils'


module CodeCode
  module Controller
    # class BaseController
    class BaseController
      include Singleton
      include CodeCode::Model
    end
  end
end
