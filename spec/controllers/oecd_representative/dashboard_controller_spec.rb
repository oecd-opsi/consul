require "rails_helper"

describe OecdRepresentative::DashboardController, type: :controller do
  describe "GET index" do
    let(:subject) { get :index }

    context "when logged in as OECD Representative" do
      before do
        sign_in create(:oecd_representative).user
        subject
      end

      it "renders the Dashboard" do
        expect(response).to render_template(:index)
      end
    end

    context "when logged in as Admin user" do
      before do
        sign_in create(:administrator).user
        subject
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("unauthorized.default"))
      end

      it "redirects back to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not logged inr" do
      before do
        subject
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("devise.failure.unauthenticated"))
      end

      it "redirects back to the sign in path" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
