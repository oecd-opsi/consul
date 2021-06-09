require_dependency Rails.root.join("app", "controllers", "notifications_controller").to_s

class NotificationsController < ApplicationController
  private

    def linkable_resource_path(notification)
      if notification.linkable_resource.is_a?(AdminNotification)
        notification.linkable_resource.link || notifications_path
      elsif notification.linkable_resource.is_a?(OecdRepresentativeRequest)
        request_link(notification.linkable_resource)
      else
        polymorphic_path(notification.linkable_resource)
      end
    end

    def request_link(linkeable_resource)
      if current_user.administrator?
        polymorphic_path([:admin, linkeable_resource])
      elsif current_user.manager?
        polymorphic_path([:management, linkeable_resource])
      else
        notifications_path
      end
    end
end
