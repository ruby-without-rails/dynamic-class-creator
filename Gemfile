# for Ubuntu
# sudo apt-get install mysql-client libmysqlclient-dev
# sudo apt-get install libpq-dev

require_relative 'lib/utils/discover_os'

source 'http://rubygems.org'
ruby '>= 2.1'

gem 'codecode-common-utils', '~> 0.1.3'

gem 'pg'
gem 'sequel' , '< 5'
gem 'sequel_enum'
# A gem 'sequel_pg' não funciona em ambiente Windows.
gem 'sequel-postgres-schemata'
gem 'sequel_pg', require: 'sequel' unless Utils::DiscoverOSUtil.os?.eql?(:windows)


gem 'pg'
gem 'sinatra'
gem 'sinatra-sequel'
gem 'sinatra-authorization'

group :test do
  gem 'faker'
  gem 'rspec'
end
