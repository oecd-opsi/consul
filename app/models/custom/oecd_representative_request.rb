class OecdRepresentativeRequest < ApplicationRecord
  extend Enumerize

  belongs_to :user, touch: true
  delegate :name, :email, :name_and_email, to: :user

  validates :user_id, :message, presence: true
  enumerize :status, in: [:pending, :accepted, :rejected], default: :pending, scope: true

  scope :with_user, -> { includes(:user) }
end
