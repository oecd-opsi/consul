require_dependency Rails.root.join("app", "models", "user").to_s

class User < ApplicationRecord
  attr_accessor :validate_display_name

  has_one :oecd_representative, dependent: :destroy
  has_many :oecd_representative_requests, dependent: :destroy
  has_many :legislation_processes,
           class_name:  "Legislation::Process",
           foreign_key: :author_id,
           inverse_of:  :author,
           dependent:   :nullify

  validates :display_name, presence: true, if: :display_name_required?

  scope :by_display_name_email_or_document_number, ->(search_string) do
    string = "%#{search_string}%"
    where("display_name ILIKE ? OR email ILIKE ? OR document_number ILIKE ?", string, string, string)
  end

  def self.first_or_initialize_for_oauth(auth)
    oauth_email           = auth.info.email
    oauth_email_verified  = auth.info.verified || auth.info.verified_email ||
      auth.dig(:extra, :raw_info, :email_verified)
    oauth_email_confirmed = oauth_email.present? && oauth_email_verified
    oauth_user            = User.find_by(email: oauth_email) if oauth_email_confirmed
    oauth_username        = auth.dig(:extra, :raw_info, "#{ENV["AUTH0_METADATA_NAMESPACE"]}app_metadata",
                                     "username") || auth.info.username || auth.info.nickname ||
      auth.info.name || auth.uid
    oauth_name            = auth.info.name || auth.dig(:extra, :raw_info, :name) || oauth_username

    user = oauth_user || User.new(
      username:         oauth_username,
      email:            oauth_email,
      display_name:     oauth_name,
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

  def oecd_representative?
    oecd_representative.present?
  end

  def standard_user?
    !(administrator? || moderator? || valuator? || manager? || poll_officer? || organization? || oecd_representative?)
  end

  def name
    organization? ? organization.name : display_name
  end

  def display_name_required?
    username_required? && validate_display_name
  end

  def self.search(term)
    term.present? ? where("email = ? OR display_name ILIKE ?", term, "%#{term}%") : none
  end

  def erase(erase_reason = nil)
    update!(
      erased_at:                Time.current,
      erase_reason:             erase_reason,
      username:                 nil,
      display_name:             nil,
      email:                    nil,
      unconfirmed_email:        nil,
      phone_number:             nil,
      encrypted_password:       "",
      confirmation_token:       nil,
      reset_password_token:     nil,
      email_verification_token: nil,
      confirmed_phone:          nil,
      unconfirmed_phone:        nil
    )
    identities.destroy_all
  end

  def promote_to_admin!
    create_administrator unless administrator?
    oecd_representative.destroy if oecd_representative?
  end

  def demote_to_user!
    administrator.destroy if administrator?
    oecd_representative.destroy if oecd_representative?
  end

  def demote_to_oecd_representative!
    administrator.destroy if administrator?
    create_oecd_representative unless oecd_representative?
  end
end
