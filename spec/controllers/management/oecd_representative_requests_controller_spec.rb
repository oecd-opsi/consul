require "rails_helper"

describe Management::OecdRepresentativeRequestsController do
  describe "GET :index" do
    let(:user) { create(:user) }
    let(:subject) { get :index }

    context "with signed in manager user" do
      before do
        sign_in_as_manager
        subject
      end

      it "response is successful" do
        expect(response).to be_success
      end
    end

    context "with signed in user who is manager but hasn't confirm the login yet" do
      let(:user) { create(:manager).user }

      before do
        sign_in user
        subject
      end

      it "redirects to manager sign in" do
        expect(response).to redirect_to management_sign_in_path
      end

      it "saves return_to in session" do
        expect(session[:return_to]).to eq(management_oecd_representative_requests_path)
      end
    end

    context "when is not permitted to visit the page" do
      let(:user) { create(:user) }

      before do
        sign_in user
        subject
      end

      it "redirects to manager sign in" do
        expect(response).to redirect_to management_sign_in_path
      end

      it "saves return_to in session" do
        expect(session[:return_to]).to eq(management_oecd_representative_requests_path)
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

    context "with signed in manager user" do
      context "when the request can be found" do
        before do
          sign_in_as_manager
          subject
        end

        it "response is successful" do
          expect(response).to be_success
        end
      end

      context "when the request cannot be found" do
        let(:oecd_representative_request) { OpenStruct.new(id: "not-existing") }
        before do
          sign_in_as_manager
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

      it "redirects to manager sign in" do
        expect(response).to redirect_to management_sign_in_path
      end

      it "saves return_to in session" do
        expect(session[:return_to]).to eq(management_oecd_representative_request_path(oecd_representative_request))
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

    context "with signed in manager user" do
      context "when the request can be found" do
        before do
          allow(RequestNotifier).to receive(:notify!)
          sign_in_as_manager
          subject
        end

        it "redirects back to request show page" do
          expect(response).to redirect_to management_oecd_representative_request_path(oecd_representative_request)
        end

        it "displays correct notification" do
          expect(flash[:notice]).to eq(I18n.t("management.oecd_representative_requests.actions.accepted"))
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
          sign_in_as_manager
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

      it "redirects to manager sign in" do
        expect(response).to redirect_to(management_sign_in_path)
      end

      it "saves return_to in session" do
        expect(session[:return_to])
          .to eq(accept_management_oecd_representative_request_path(oecd_representative_request))
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

    context "with signed in manager user" do
      context "when the request can be found" do
        before do
          allow(RequestNotifier).to receive(:notify!)
          sign_in_as_manager
          subject
        end

        it "redirects back to request show page" do
          expect(response).to redirect_to(management_oecd_representative_request_path(oecd_representative_request))
        end

        it "displays correct notification" do
          expect(flash[:notice]).to eq(I18n.t("management.oecd_representative_requests.actions.rejected"))
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
          sign_in_as_manager
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

      it "redirects to manager sign in" do
        expect(response).to redirect_to management_sign_in_path
      end

      it "saves return_to in session" do
        expect(session[:return_to])
          .to eq(reject_management_oecd_representative_request_path(oecd_representative_request))
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
