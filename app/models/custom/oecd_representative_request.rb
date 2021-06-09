class OecdRepresentativeRequest < ApplicationRecord
  extend Enumerize
  include Notifiable

  belongs_to :user, touch: true
  delegate :name, :email, :name_and_email, to: :user

  validates :user_id, :message, presence: true
  enumerize :status, in: [:pending, :accepted, :rejected], default: :pending, scope: true

  scope :with_user, -> { includes(:user) }
  delegate :oecd_representative?, to: :user, prefix: true
  delegate :email_on_direct_message?, to: :user, prefix: true

  def accept!
    user.create_oecd_representative
    update!(status: :accepted)
  end

  def reject!
    update(status: :rejected)
  end

  def notifiable_title
    "OECD Representative Request"
  end

  def notifiable_body
    message
  end
end
