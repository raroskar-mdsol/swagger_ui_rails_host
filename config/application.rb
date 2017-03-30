require_relative 'boot'
require 'rails'
# require 'active_model/railtie'
# require 'active_record/railtie'
require 'action_controller/railtie'
require 'rails/test_unit/railtie'
require "sprockets/railtie" if Rails.env.development?

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Swagger_UI_RAILS_HOST
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.autoload_paths += %W(#{config.root}/app/graph)
    config.autoload_paths += %W(#{config.root}/app/graph/base_types)

    config.middleware.delete Rack::ETag
    config.middleware.delete Rack::ConditionalGet

    require 'rack/accept'
    config.middleware.use Rack::Accept

    config.action_controller.action_on_unpermitted_parameters = :raise
  end
end
