require "rails_helper"

describe Users::RegistrationsController do
  context "when Auth0 login is enabled" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      Setting["feature.auth0_login"] = true
    end

    after do
      Setting["feature.auth0_login"] = false
    end

    it "redirects user to WordPress Sign Up page with redirect_uri given" do
      get :new
      expected_redirect_url = "#{ENV["WORDPRESS_SIGN_UP_URL"]}?redirect_uri=#{URI::encode(confirm_login_url)}"
      expect(response).to redirect_to(expected_redirect_url)
    end
  end

  describe "POST check_username" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "when username is available" do
      it "returns true with no error message" do
        get :check_username, params: { username: "available username" }

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:available]).to be true
        expect(data[:message]).to eq I18n.t("devise_views.users.registrations.new.username_is_available")
      end
    end

    context "when username is not available" do
      it "returns false with an error message" do
        user = create(:user)
        get :check_username, params: { username: user.username }

        data = JSON.parse response.body, symbolize_names: true
        expect(data[:available]).to be false
        expect(data[:message]).to eq I18n.t("devise_views.users.registrations.new.username_is_not_available")
      end
    end
  end
end
