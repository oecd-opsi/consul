module Consul
  class Application < Rails::Application
    if ENV["SENTRY_DSN"]
      Raven.configure do |config|
        config.dsn = ENV["SENTRY_DSN"]
      end
    end
  end
end
