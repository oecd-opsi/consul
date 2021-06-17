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
      request_notifiable_action
    else
      "comments_on"
    end
  end

  def request_notifiable_action
    if user.administrator? || user.manager?
      "oecd_representative_request_created"
    else
      "oecd_representative_request_#{notifiable.status}"
    end
  end
end
