require_dependency Rails.root.join("app", "models", "comment").to_s

class Comment < ApplicationRecord
  include Custom::GenerateCsvData
end
