require "rails_helper"

describe RequestNotifier do
  let(:request) { create(:oecd_representative_request) }
  let(:user) { create(:administrator).user }
  let(:mailer_mock) { double }

  describe "#notify!" do
    before do
      allow(Custom::NotificationsMailer).to receive(mailer_method)
                                              .and_return(mailer_mock)
      allow(mailer_mock).to receive(:deliver_later)
    end

    context "when new request created" do
      let(:mailer_method) { :new_oecd_representative_request }

      it "sends an email to user" do
        RequestNotifier.notify!(user, request, :new)
        expect(Custom::NotificationsMailer).to have_received(mailer_method)
                                                 .with(user.id, request.id)
        expect(mailer_mock).to have_received(:deliver_later)
      end

      it "creates a new notification" do
        expect { RequestNotifier.notify!(user, request, :new) }
          .to change { Notification.where(user: user, notifiable: request).count }.by(1)
      end
    end

    context "when new request accepted" do
      let(:user) { request.user }
      let(:mailer_method) { :accepted_oecd_representative_request }

      it "sends an email to user" do
        RequestNotifier.notify!(user, request, :accepted)
        expect(Custom::NotificationsMailer).to have_received(mailer_method)
                                                 .with(user.id, request.id)
        expect(mailer_mock).to have_received(:deliver_later)
      end

      it "creates a new notification" do
        expect { RequestNotifier.notify!(user, request, :accepted) }
          .to change { Notification.where(user: user, notifiable: request).count }.by(1)
      end
    end

    context "when new request rejected" do
      let(:user) { request.user }
      let(:mailer_method) { :rejected_oecd_representative_request }

      it "sends an email to user" do
        RequestNotifier.notify!(user, request, :rejected)
        expect(Custom::NotificationsMailer).to have_received(mailer_method)
                                                 .with(user.id, request.id)
        expect(mailer_mock).to have_received(:deliver_later)
      end

      it "creates a new notification" do
        expect { RequestNotifier.notify!(user, request, :rejected) }
          .to change { Notification.where(user: user, notifiable: request).count }.by(1)
      end
    end
  end
end
