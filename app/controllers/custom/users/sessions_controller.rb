class Users::SessionsController < Devise::SessionsController
  def new
    if Setting["feature.auth0_login"]
      redirect_to "#{ENV["WORDPRESS_SIGN_UP_URL"]}?redirect_uri=#{confirm_login_url}"
    else
      super
    end
  end

  private

    def after_sign_in_path_for(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    def after_sign_out_path_for(resource)
      request.referer.present? && !request.referer.match("management") ? request.referer : super
    end

    def verifying_via_email?
      return false if resource.blank?

      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end
end
