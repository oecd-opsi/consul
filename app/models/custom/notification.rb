require_dependency Rails.root.join("app", "models", "notification").to_s

class Notification < ApplicationRecord
  def notifiable_action
    case notifiable_type
    when "ProposalNotification"
      "proposal_notification"
    when "Comment"
      "replies_to"
    when "AdminNotification"
      nil
    when "OecdRepresentativeRequest"
      "oecd_representative_request_created"
    else
      "comments_on"
    end
  end
end
