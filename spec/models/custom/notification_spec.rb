require "rails_helper"

describe Notification do
  describe "#notification_action" do
    let(:notifiable) { create(:oecd_representative_request) }
    let(:admin) { create(:administrator).user }
    let(:requester) { notifiable.user }

    it "returns correct action when there is a new OECD Representative Request" do
      notification = create(:notification, user: admin, notifiable: notifiable)

      expect(notification.notifiable_action).to eq "oecd_representative_request_created"
    end

    it "returns correct action when the OECD Representative Request has been accepted" do
      notifiable.accept!
      notification = create(:notification, user: requester, notifiable: notifiable)

      expect(notification.notifiable_action).to eq "oecd_representative_request_accepted"
    end

    it "returns correct action when the OECD Representative Request has been rejected" do
      notifiable.reject!
      notification = create(:notification, user: requester, notifiable: notifiable)

      expect(notification.notifiable_action).to eq "oecd_representative_request_rejected"
    end
  end
end
