require_relative 'lib/utils/discover_os'

source 'http://rubygems.org'

ruby '>= 1.9'

gem 'codecode-common-utils', '~> 0.1.3'

gem 'pg'
gem 'sequel' , '< 5'
# A gem 'sequel_pg' não funciona em ambiente Windows.
gem 'sequel-postgres-schemata'
gem 'sequel_pg', require: 'sequel' unless CodeCode::Utils::DiscoverOSUtil.os?.eql?(:windows)

group :test do
  gem 'faker'
  gem 'rspec'
end
