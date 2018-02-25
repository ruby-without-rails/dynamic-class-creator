# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

require_relative 'api/app'

ENV['TZ'] = 'America/Sao_Paulo'

Rack::Handler.default.run(App, Port: 6669, Host: '0.0.0.0')
