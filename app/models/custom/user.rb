require_dependency Rails.root.join("app", "models", "user").to_s

class User < ApplicationRecord
  def self.first_or_initialize_for_oauth(auth)
    oauth_email           = auth.info.email
    oauth_email_verified  = auth.info.verified || auth.info.verified_email ||
      auth.dig(:extra, :raw_info, :email_verified)
    oauth_email_confirmed = oauth_email.present? && oauth_email_verified
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed

    oauth_username = auth.dig(:extra, :raw_info, "#{ENV["AUTH0_METADATA_NAMESPACE"]}app_metadata",
                              "username") || auth.info.name || auth.uid

    user = oauth_user || User.new(
      username:         oauth_username,
      email:            oauth_email,
      oauth_email:      oauth_email,
      password:         Devise.friendly_token[0, 20],
      terms_of_service: "1",
      confirmed_at:     oauth_email_confirmed ? DateTime.current : nil
    )
    user.skip_confirmation_notification! if Setting["feature.auth0_login"]
    user
  end

  def logins_via_password?
    identities.authenticated_by_password.any?
  end

  def login_via_password_id
    return nil unless logins_via_password?

    identities.authenticated_by_password.first.uid
  end

  def synchronize_with_auth!(auth)
    oauth_email           = auth.dig(:info, :email)
    oauth_email_confirmed = oauth_email.present? && auth.dig(:extra, :raw_info, :email_verified)
    return unless oauth_email_confirmed

    confirm if !confirmed? || pending_reconfirmation?

    return if oauth_email == email

    self.email = oauth_email
    self.skip_reconfirmation!
    save!
  end
end
