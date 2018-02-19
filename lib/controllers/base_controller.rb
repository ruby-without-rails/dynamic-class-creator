require 'singleton'
require 'codecode/common/utils'
require_relative '../../lib/models/code_language'
require_relative '../../lib/models/project'


module CodeCode
  module Controller
    # class BaseController
    class BaseController
      include Singleton
      include CodeCode::Model
    end
  end
end
