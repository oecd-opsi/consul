module Custom::Urlable
  extend ActiveSupport::Concern
  HOST = ENV["SERVER_NAME"]

  def build_url_for(path, resource, options = {})
    Rails.application.routes.url_helpers.send(path, resource, options.merge(host: HOST))
  end
end
