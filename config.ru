# frozen_string_literal: true
require_relative 'api/app'

Rack::Handler.default.run(App, Port: 9494, Host: '0.0.0.0')