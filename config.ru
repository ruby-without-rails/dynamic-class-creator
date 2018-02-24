# frozen_string_literal: true
require_relative 'api/app'

ENV['TZ'] = 'America/Sao_Paulo'

Rack::Handler.default.run(App, Port: 9494, Host: '0.0.0.0')