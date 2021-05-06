require_dependency Rails.root.join("app", "models", "legislation", "annotation").to_s

class Legislation::Annotation < ApplicationRecord
  has_one :process, through: :draft_version
  delegate :title, to: :process, prefix: true
end
