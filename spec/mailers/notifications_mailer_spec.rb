require "rails_helper"

describe NotificationsMailer do
  describe "#new_oecd_representative_request" do
    let(:request) { create(:oecd_representative_request) }
    let(:email) { NotificationsMailer.new_oecd_representative_request(user.id, request.id) }

    context "when recipient is an admin" do
      let(:user) { create(:administrator).user }

      it "sets correct subject " do
        expect(email.subject).to eq(I18n.t("mailers.new_oecd_representative_request.subject"))
      end

      it "includes correct resource link" do
        expect(email.body).to include(admin_oecd_representative_request_url(request))
      end
    end

    context "when recipient is an manager" do
      let(:user) { create(:manager).user }

      it "sets correct subject " do
        expect(email.subject).to eq(I18n.t("mailers.new_oecd_representative_request.subject"))
      end

      it "includes correct resource link" do
        expect(email.body).to include(management_oecd_representative_request_url(request))
      end
    end
  end

  describe "#accepted_oecd_representative_request" do
    let(:request) { create(:oecd_representative_request) }
    let(:email) { NotificationsMailer.accepted_oecd_representative_request(user.id, request.id) }

    let(:user) { request.user }

    it "sets correct subject " do
      expect(email.subject).to eq(I18n.t("mailers.accepted_oecd_representative_request.subject"))
    end

    it "uses correct email body" do
      expect(email.body).to include(I18n.t("mailers.accepted_oecd_representative_request.content"))
    end
  end

  describe "#rejected_oecd_representative_request" do
    let(:request) { create(:oecd_representative_request) }
    let(:email) { NotificationsMailer.rejected_oecd_representative_request(user.id, request.id) }

    let(:user) { request.user }

    it "sets correct subject " do
      expect(email.subject).to eq(I18n.t("mailers.rejected_oecd_representative_request.subject"))
    end

    it "uses correct email body" do
      expect(email.body).to include(I18n.t("mailers.rejected_oecd_representative_request.content"))
    end
  end
end
