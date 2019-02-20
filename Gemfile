# for Ubuntu
# sudo apt-get install mysql-client libmysqlclient-dev
# sudo apt-get install libpq-dev

require_relative 'lib/utils/discover_os'

source 'http://rubygems.org'
ruby '2.4.5'
gem 'bundler'

gem 'pg'
gem 'sequel'
gem 'sequel_enum'
# gem 'sequel_pg' not work's in Windows.
gem 'sequel_pg', require: 'sequel' unless Utils::DiscoverOS.os?.eql?(:windows)
gem 'inflector'
gem 'rack'
gem 'rack-contrib'
gem 'sinatra'
gem 'sinatra-cross_origin'
gem 'sinatra-sequel'
gem 'sinatra-authorization'
gem 'sinatra-contrib'


group :test do
  gem 'faker'
  gem 'rspec'
end
