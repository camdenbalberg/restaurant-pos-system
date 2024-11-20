require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PandaWebAppBackend
  class Application < Rails::Application
    # config.middleware.use ActionDispatch::Session::CookieStore, key: '_my_app_session', secure: Rails.env.production?
    # config.secret_key_base = ENV['SECRET_KEY_BASE'] if ENV['SECRET_KEY_BASE'].present?
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = false
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.hosts << "backend"
    config.hosts << "frontend"
    config.hosts << "localhost"
  end
end
