require "rails_helper"

describe Notification do
  describe "#notification_action" do
    let(:notifiable) { create(:oecd_representative_request) }

    it "returns correct action when there is a new OECD Representative Request" do
      notification = create(:notification, notifiable: notifiable)

      expect(notification.notifiable_action).to eq "oecd_representative_request_created"
    end
  end
end
