require "rails_helper"

describe OecdRepresentativeRequestsController do
  describe "GET new" do
    let(:user) { create(:user) }

    context "without any pending requests" do
      before do
        sign_in user
        get :new
      end

      it "response is successful" do
        expect(response).to be_success
      end
    end

    context "with pending request" do
      before do
        sign_in user
        create(:oecd_representative_request, user: user)
        get :new
      end

      it "redirects back to account page" do
        expect(response).to redirect_to(account_path)
      end

      it "displays flash alert" do
        expect(flash[:alert]).to eq(I18n.t("users.oecd_represetative_requests.flash.already_sent"))
      end
    end

    context "when is not permitted to visit the page" do
      let(:user) { create(:administrator).user }

      before do
        sign_in user
        get :new
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("unauthorized.manage.all",
                                           action:  :new,
                                           subject: :'oecd representative request'))
      end

      it "redirects back to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end

    context "when no logged in user" do
      before do
        get :new
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("unauthorized.manage.all",
                                           action:  :new,
                                           subject: :'oecd representative request'))
      end

      it "redirects back to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST create" do
    let(:user) { create(:user) }
    let(:subject) { post :create, params: { oecd_representative_request: resource_params } }
    let(:resource_params) { { message: Faker::Lorem.sentence } }
    let(:admin) { create(:administrator) }
    let(:manager) { create(:manager) }
    let(:mailer_mock) { double }

    context "without any pending requests" do
      before do
        sign_in user
        allow(Custom::NotificationsMailer).to receive(:new_oecd_representative_request).and_return(mailer_mock)
        allow(mailer_mock).to receive(:deliver_later)
        admin
        manager
        subject
      end

      context "with valid resource" do
        let(:resource_params) { { message: Faker::Lorem.sentence } }

        it "shows success message" do
          expect(flash[:notice]).to eq(I18n.t("users.oecd_represetative_requests.flash.create"))
        end

        it "redirects back to account page" do
          expect(response).to redirect_to(account_path)
        end

        it "creates new request for user" do
          expect(user.oecd_representative_requests.with_status(:pending)).not_to be_empty
        end

        it "sends notifications to admins and managers" do
          expect(Custom::NotificationsMailer).to have_received(:new_oecd_representative_request).twice
        end

        it "sends notification to admins" do
          expect(Custom::NotificationsMailer)
            .to have_received(:new_oecd_representative_request).with(
              admin.id,
              assigns[:oecd_representative_request].id
            )
        end

        it "sends notificationsto manager" do
          expect(Custom::NotificationsMailer)
            .to have_received(:new_oecd_representative_request).with(
              manager.id,
              assigns[:oecd_representative_request].id
            )
        end
      end

      context "with invalid resource" do
        let(:resource_params) { { message: nil } }

        it "renders the form once again" do
          expect(response).to render_template(:new)
        end

        it "does not create new request for user" do
          expect(user.oecd_representative_requests.with_status(:pending)).to be_empty
        end

        it "does not send any notifications" do
          expect(Custom::NotificationsMailer).not_to have_received(:new_oecd_representative_request)
        end
      end
    end

    context "with pending request" do
      before do
        sign_in user
        create(:oecd_representative_request, user: user)
        subject
      end

      it "redirects back to account page" do
        expect(response).to redirect_to(account_path)
      end

      it "displays flash alert" do
        expect(flash[:alert]).to eq(I18n.t("users.oecd_represetative_requests.flash.already_sent"))
      end
    end

    context "when is not permitted to visit the page" do
      let(:user) { create(:administrator).user }

      before do
        sign_in user
        subject
      end

      it "shows flash error" do
        expect(flash[:alert]).to eq(I18n.t("unauthorized.manage.all",
                                           action:  :create,
                                           subject: :'oecd representative request'))
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
        expect(flash[:alert]).to eq(I18n.t("unauthorized.manage.all",
                                           action:  :create,
                                           subject: :'oecd representative request'))
      end

      it "redirects back to the root path" do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
