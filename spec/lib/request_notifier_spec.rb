require "rails_helper"

describe RequestNotifier do
  let(:request) { create(:oecd_representative_request) }
  let(:user) { create(:administrator).user }
  let(:mailer_mock) { double }

  describe "#notify!" do
    before do
      allow(Custom::NotificationsMailer).to receive(:new_oecd_representative_request)
                                              .and_return(mailer_mock)
      allow(mailer_mock).to receive(:deliver_later)
    end

    it "sends an email to user" do
      RequestNotifier.notify!(user, request)
      expect(Custom::NotificationsMailer).to have_received(:new_oecd_representative_request)
                                               .with(user.id, request.id)
      expect(mailer_mock).to have_received(:deliver_later)
    end

    it "creates a new notification" do
      expect { RequestNotifier.notify!(user, request) }
        .to change { Notification.where(user: user, notifiable: request).count }.by(1)
    end
  end
end
