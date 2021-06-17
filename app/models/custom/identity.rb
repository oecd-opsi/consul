require_dependency Rails.root.join("app", "models", "identity").to_s

class Identity < ApplicationRecord
  AUTH0_PASSWORD_PREFIX = "auth0|".freeze

  scope :authenticated_by_password, -> { where("uid LIKE :prefix", prefix: "#{AUTH0_PASSWORD_PREFIX}%") }

  def self.synchronize_or_create_from_oauth(auth)
    identity = where(uid: auth.uid, provider: auth.provider).first_or_create!
    identity.synchronize_user!(auth)

    identity
  end

  def synchronize_user!(auth)
    return unless user

    user.synchronize_with_auth!(auth)
  end
end
