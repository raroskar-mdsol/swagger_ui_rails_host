source 'https://rubygems.org'

gem 'rails', '~> 5.0.1'
gem 'redis-rails', '~> 5.0', '>= 5.0.1'
gem 'puma', '~> 3.0'
gem 'json', '~> 2.0', '>= 2.0.3'

gem 'graphql', '~> 1.4', '>= 1.4.3'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# proprietory gems
gem 'mauth-client', git: 'git@github.com:mdsol/mauth-client-ruby.git', tag: 'v4.0.2'

gem 'dice_bag', '~> 1.2', '>= 1.2.1'
gem 'rack-accept', '~> 0.4.5'
gem 'rack-cache', '~> 1.7'

# proprietary gems
gem 'rack-app_status', require: 'rack/app_status', git: 'git@github.com:mdsol/rack-app_status.git', tag: '0.1.5'
gem 'astinus', git: 'git@github.com:mdsol/astinus.git', tag: '2.3.1'
gem 'monitor_wares', git: 'git@github.com:mdsol/monitor_wares.git', tag: '0.10.2'
gem 'mdsol-tools', git: 'git@github.com:mdsol/mdsol-tools.git', tag: 'v1.0.0'
gem 'impersonation_middleware', :git => 'git@github.com:mdsol/impersonation_middleware.git', tag: 'v0.0.6'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5'
  gem 'rspec-collection_matchers', '~> 1.1', '>= 1.1.3'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'graphiql-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'coffee-rails'
end

group :test do
  gem 'knapsack_pro', '~> 0.26.0'
  gem 'brakeman', '~> 3.5'
# TODO: uncomment when backed by database
#   gem 'consistency_fail', '~> 0.3.5'
  gem 'simplecov', '~> 0.13.0', require: false
  gem 'simplecov-html', '~> 0.10.0', require: false
  gem 'simplecov-rcov', '~> 0.2.3', require: false
end

