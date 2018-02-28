require 'sequel'

module Models

  # @class [Configuration]
  class Configuration < Sequel::Model(:configurations)

    # Set primary key and relationships:
    set_primary_key :key
    unrestrict_primary_key

    class << self
      def save_configuration(key, value)
        new{ |c|
          c.key = key
          c.value = value
          c.save
        }
      end

      def app_version
        conf = where(key: 'version').first
        conf.values
      end

      def get_configuration(key)
        where(key: key).map(:values)
      end

      def list_configurations
        all.map(&:values)
      end

      def list_apis(controller)
        routes = controller.routes

        # %w(POST GET DELETE OPTIONS PUT).each{|method|
        #   local_variable_set("#{method.downcase}_routes".to_sym, routes[method].collect {|r| r.first.to_s})
        # }

        post_routes = routes['POST']&.collect {|r| r.first.to_s}
        get_routes = routes['GET']&.collect {|r| r.first.to_s}
        delete_routes = routes['DELETE']&.collect {|r| r.first.to_s}
        options_routes = routes['OPTIONS']&.collect {|r| r.first.to_s}
        put_routes = routes['PUT']&.collect {|r| r.first.to_s}
        patch_routes = routes['PATCH']&.collect {|r| r.first.to_s}

        {post: post_routes, get: get_routes, delete: delete_routes, options: options_routes, put: put_routes, patch: patch_routes}
      end
    end
  end
end

