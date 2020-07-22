class Auth0UserUpdater
  def initialize(user, user_params)
    @email                 = user_params[:email]
    @password              = user_params[:password]
    @password_confirmation = user_params[:password_confirmation]
    @user                  = user
  end

  def auth0_client
    @auth0_client ||= Auth0Client.new(
      client_id:     Rails.application.secrets.auth0_key,
      client_secret: Rails.application.secrets.auth0_secret,
      domain:        Rails.application.secrets.auth0_domain,
      api_version:   2
    )
  end

  def updating_email?
    !@email.blank?
  end

  def valid?
    updating_email? ? email_valid? : password_valid?
  end

  def update
    return unless valid?

    update_user(updating_email? ? { email: @email } : { password: @password })
  end

  def self.process(*args)
    new(*args).process
  end

  def process
    update!
    @user
  end

  private

    def email_valid?
      @user.email = @email
      @user.valid?
      @user.errors.add(:email, :taken) if email_taken?

      @user.errors.empty?
    end

    def password_valid?
      @user.password              = @password
      @user.password_confirmation = @password_confirmation
      @user.valid?
    end

    def email_taken?
      params = {
        q:      "email:#{@email}",
        fields: "email,user_id"
      }
      auth0_client.users(params).any?
    end

    def update_user(params)
      default_params = {
        verify_email: updating_email?,
        connection:   "Username-Password-Authentication"
      }
      auth0_client.update_user(@user.login_via_password_id, params.merge(default_params))
      return unless updating_email?

      @user.skip_confirmation_notification!
      @user.save!
    rescue Auth0::BadRequest
      @user.errors.add(updating_email? ? :email : :password, :invalid)
    end
end
