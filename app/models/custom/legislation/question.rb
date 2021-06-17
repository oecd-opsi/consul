require_dependency Rails.root.join("app", "models", "legislation", "question").to_s

class Legislation::Question < ApplicationRecord
  delegate :title, to: :process, prefix: true
end
