module Consul
  class Application < Rails::Application
    if ENV["SENTRY_DSN"]
      Raven.configure do |config|
        config.dsn = ENV["SENTRY_DSN"]
        config.environment = ENV["SENTRY_ENV"]
      end
    end
  end
end
