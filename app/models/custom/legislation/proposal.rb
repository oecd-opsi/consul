require_dependency Rails.root.join("app", "models", "legislation", "proposal").to_s

class Legislation::Proposal < ApplicationRecord
  delegate :title, to: :process, prefix: true
end
