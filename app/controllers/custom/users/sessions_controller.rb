class Users::SessionsController < Devise::SessionsController
  def new
    if Setting["feature.auth0_login"]
      redirect_to "#{ENV["WORDPRESS_SIGN_IN_URL"]}?redirect_uri=#{URI::encode(confirm_login_url)}"
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
      if Setting["feature.auth0_login"]
        auth0_after_sign_out_path
      else
        request.referer.present? && !request.referer.match("management") ? request.referer : super
      end
    end

    def auth0_after_sign_out_path
      redirect_url = "#{ENV["WORDPRESS_SIGN_OUT_URL"]}"

      # if the logout was triggered from Consul, ensure that at the end
      # the user will be redirected back to Consul
      if !request.referer.present? || request.referer.starts_with?(root_url)
        redirect_url += "?redirect_uri=#{URI::encode(root_url)}"
      end
      redirect_url
    end

    def verifying_via_email?
      return false if resource.blank?

      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end
end
