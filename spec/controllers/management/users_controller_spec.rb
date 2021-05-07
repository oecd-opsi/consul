require "rails_helper"

describe Management::UsersController do
  describe "logout" do
    it "removes user data from the session" do
      session[:manager] = { user_key: "31415926", date: "20151031135905", login: "JJB033" }
      session[:document_type] = "1"
      session[:document_number] = "12345678Z"

      get :logout

      expect(session[:manager]).to eq(user_key: "31415926", date: "20151031135905", login: "JJB033")
      expect(session[:document_type]).to be_nil
      expect(session[:document_number]).to be_nil
      expect(response).to be_redirect
    end
  end

  describe "GET promote_to_oecd_representative" do
    let(:manager) { create(:manager).user }
    before do
      sign_in manager
      session[:manager] = { "login" => "manager_user_#{manager.id}" }
      session[:document_type] = nil
      session[:document_number] = nil
    end

    context "when user can be promoted to Oecd representative" do
      let(:user) { create(:user) }

      before { get :promote_to_oecd_representative, params: { id: user.id } }

      it "promotes the user to admin" do
        expect(user.reload).to be_oecd_representative
      end

      it "shows flash notice" do
        expect(flash[:notice]).to eq(I18n.t("admin.users.promote_to_oecd_representative.success"))
      end

      it "redirects back to users list" do
        expect(response).to redirect_to(management_document_verifications_path)
      end
    end

    context "when the user cannot be promoted to OECD Representative" do
      let(:user) { create(:oecd_representative).user }

      it "raises Access Denied" do
        expect { get :promote_to_oecd_representative, params: { id: user.id } }
          .to raise_error(CanCan::AccessDenied)
      end
    end

    context "when the user cannot be found" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :promote_to_oecd_representative, params: { id: "not-existing" } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
