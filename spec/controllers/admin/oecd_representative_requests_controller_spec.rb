require "rails_helper"

describe Admin::OecdRepresentativeRequestsController do
  describe "GET :index" do
    let(:user) { create(:user) }
    let(:subject) { get :index }

    context "with signed in admin user" do
      let(:user) { create(:administrator).user }
      before do
        sign_in user
        subject
      end

      it "response is successful" do
        expect(response).to be_success
      end
    end

    context "when is not permitted to visit the page" do
      let(:user) { create(:user) }

      before do
        sign_in user
        subject
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("unauthorized.default"))
      end

      it "redirects back to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when no logged in user" do
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

  describe "GET :show" do
    let(:user) { create(:user) }
    let(:oecd_representative_request) { create(:oecd_representative_request) }
    let(:subject) { get :show, params: { id: oecd_representative_request.id } }

    context "with signed in admin user" do
      let(:user) { create(:administrator).user }

      context "when the request can be found" do
        before do
          sign_in user
          subject
        end

        it "response is successful" do
          expect(response).to be_success
        end
      end

      context "when the request cannot be found" do
        let(:oecd_representative_request) { OpenStruct.new(id: "not-existing") }
        before do
          sign_in user
        end

        it "returns Record not Found error" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "when is not permitted to visit the page" do
      let(:user) { create(:user) }

      before do
        sign_in user
        subject
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("unauthorized.default"))
      end

      it "redirects back to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when no logged in user" do
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

  describe "GET :accept" do
    let(:user) { create(:user) }
    let(:oecd_representative_request) { create(:oecd_representative_request) }
    let(:subject) { get :accept, params: { id: oecd_representative_request.id } }

    context "with signed in admin user" do
      let(:user) { create(:administrator).user }

      context "when the request can be found" do
        before do
          allow(RequestNotifier).to receive(:notify!)
          sign_in user
          subject
        end

        it "redirects back to request show page" do
          expect(response).to redirect_to admin_oecd_representative_request_path(oecd_representative_request)
        end

        it "displays correct notification" do
          expect(flash[:notice]).to eq(I18n.t("admin.oecd_representative_requests.actions.accepted"))
        end

        it "accepts the request" do
          expect(oecd_representative_request.reload.status).to eq(:accepted)
        end

        it "notifies the requester" do
          expect(RequestNotifier).to have_received(:notify!).with(oecd_representative_request.user,
                                                                  oecd_representative_request,
                                                                  :accepted)
        end
      end

      context "when the request cannot be found" do
        let(:oecd_representative_request) { OpenStruct.new(id: "not-existing") }
        before do
          sign_in user
        end

        it "returns Record not Found error" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "when is not permitted to visit the page" do
      let(:user) { create(:user) }

      before do
        sign_in user
        subject
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("unauthorized.default"))
      end

      it "redirects back to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when no logged in user" do
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

  describe "GET :reject" do
    let(:user) { create(:user) }
    let(:oecd_representative_request) { create(:oecd_representative_request) }
    let(:subject) { get :reject, params: { id: oecd_representative_request.id } }

    context "with signed in admin user" do
      let(:user) { create(:administrator).user }

      context "when the request can be found" do
        before do
          allow(RequestNotifier).to receive(:notify!)
          sign_in user
          subject
        end

        it "redirects back to request show page" do
          expect(response).to redirect_to admin_oecd_representative_request_path(oecd_representative_request)
        end

        it "displays correct notification" do
          expect(flash[:notice]).to eq(I18n.t("admin.oecd_representative_requests.actions.rejected"))
        end

        it "rejects the request" do
          expect(oecd_representative_request.reload.status).to eq(:rejected)
        end

        it "notifies the requester" do
          expect(RequestNotifier).to have_received(:notify!).with(oecd_representative_request.user,
                                                                  oecd_representative_request,
                                                                  :rejected)
        end
      end

      context "when the request cannot be found" do
        let(:oecd_representative_request) { OpenStruct.new(id: "not-existing") }
        before do
          sign_in user
        end

        it "returns Record not Found error" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "when is not permitted to visit the page" do
      let(:user) { create(:user) }

      before do
        sign_in user
        subject
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("unauthorized.default"))
      end

      it "redirects back to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when no logged in user" do
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
