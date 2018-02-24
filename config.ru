# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

require_relative 'api/app'

ENV['TZ'] = 'America/Sao_Paulo'

use Rack::Parser, content_types: {
  'application/json' => proc { |body| ::MultiJson.decode body, :symbolize_keys => true }
}

Rack::Handler.default.run(App, Port: 9494, Host: '0.0.0.0')
