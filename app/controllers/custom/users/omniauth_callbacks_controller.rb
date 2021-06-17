class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    sign_in_with :twitter_login, :twitter
  end

  def facebook
    sign_in_with :facebook_login, :facebook
  end

  def google_oauth2
    sign_in_with :google_login, :google_oauth2
  end

  def wordpress_oauth2
    sign_in_with :wordpress_login, :wordpress_oauth2
  end

  def auth0
    sign_in_with :auth0_login, :auth0
  end

  def after_sign_in_path_for(resource)
    if resource.registering_with_oauth
      finish_signup_path
    else
      super(resource)
    end
  end

  private

    def sign_in_with(feature, provider)
      raise ActionController::RoutingError.new("Not Found") unless Setting["feature.#{feature}"]

      auth = request.env["omniauth.auth"]

      identity = Identity.synchronize_or_create_from_oauth(auth)
      @user = current_user || identity.user || User.first_or_initialize_for_oauth(auth)

      if save_user
        identity.update!(user: @user)
        sign_in_and_redirect @user, event: :authentication

        # display default message for successful sign in
        set_flash_message("signed_in", :signed_in, scope: "devise.sessions")if is_navigational_format?
      else
        session["devise.#{provider}_data"] = auth
        redirect_to new_user_registration_path
      end
    end

    def save_user
      @user.save || @user.save_requiring_finish_signup
    end
end
