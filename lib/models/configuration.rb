# frozen_string_literal: true
require 'requires'

module Models
  include Models::Base

  # @class [Configuration]
  class Configuration < BaseModel

    # Set Configuration dataset:
    set_dataset Models::DATABASE[:configuration]

    # Set primary key and relationships:
    set_primary_key :key

    def initialize; end

    class << self
      def save_configuration(name, value)
        c = Configuration.new
        c.name = name
        c.value = value
        c.save
      end

      def get_version
        conf = Configuration.where(name: 'version').first
        conf.values
      end

      def get_configuration(name)
        conf = Configuration.where(name: name).first
        conf.values
      end

      def list_configurations
        Configuration.all.map(&:values)
      end

      def list_apis(controller)
        routes = controller.routes

        # %w(POST GET DELETE OPTIONS PUT PATCH).each{|method|
        #   const_set("#{method.downcase}_routes", routes[method].collect {|r| r.first.to_s})
        # }

        post_routes = routes['POST'].collect {|r| r.first.to_s}
        get_routes = routes['GET'].collect {|r| r.first.to_s}
        delete_routes = routes['DELETE'].collect {|r| r.first.to_s}
        options_routes = routes['OPTIONS'].collect {|r| r.first.to_s}
        put_routes = routes['PUT'].collect {|r| r.first.to_s}
        patch_routes = routes['PATCH'].collect {|r| r.first.to_s}

        {post: post_routes, get: get_routes, delete: delete_routes, options: options_routes, put: put_routes, patch: patch_routes}
      end
    end
  end
end

