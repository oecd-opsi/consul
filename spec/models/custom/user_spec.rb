require "rails_helper"

describe User do
  let(:user) { create(:user) }

  describe "synchronize_with_auth!" do
    let(:user) { create(:user, confirmed_at: nil) }
    let(:auth) do
      OpenStruct.new(uid:      "uid",
                     provider: "provider",
                     info:     auth_info,
                     extra:    auth_extra)
    end
    let(:auth_info) { OpenStruct.new(email: user.email) }
    let(:auth_extra) { OpenStruct.new(raw_info: { email_verified: 1 }) }

    context "user has not been be confirmed yet" do
      let(:auth_extra) { OpenStruct.new(raw_info: {}) }

      it "does not confirm user" do
        user.synchronize_with_auth!(auth)
        expect(user.reload.confirmed?).to be_falsey
      end
    end

    context "user account has been be confirmed in Oauth" do
      it "confirms user" do
        user.synchronize_with_auth!(auth)
        expect(user.reload.confirmed?).to be_truthy
      end
    end

    context "user email has been be changed in Oauth" do
      let(:new_email) { "new_email@example.com" }
      let(:auth_info) { OpenStruct.new(email: new_email) }
      before { user.synchronize_with_auth!(auth) }

      it "confirms user" do
        expect(user.reload.confirmed?).to be_truthy
      end

      it "updates user email to the one from Oauth" do
        expect(user.reload.email).to eq new_email
      end
    end
  end

  describe "logins_via_password?" do
    before { identity }

    context "when user logs in using email and password on Auth0" do
      let(:identity) { create(:identity, :authenticated_by_password, user: user) }

      it "is true if" do
        expect(user.logins_via_password?).to be_truthy
      end
    end

    context "when user uses different login method on Auth0" do
      let(:identity) { create(:identity, user: user) }

      it "is false" do
        expect(user.logins_via_password?).to be_falsey
      end
    end
  end

  describe "login_via_password_id" do
    before { identity }

    context "when user logs in using email and password on Auth0" do
      let(:identity) { create(:identity, :authenticated_by_password, user: user) }

      it "returns appropriate identity UID" do
        expect(user.login_via_password_id).to eq identity.uid
      end
    end

    context "when user uses different login method on Auth0" do
      let(:identity) { create(:identity, user: user) }

      it "is nil" do
        expect(user.login_via_password_id).to be_nil
      end
    end
  end

  describe "first_or_initialize_for_oauth" do
    let(:email) { "user@example.com" }
    let(:name) { "User" }
    let(:auth) do
      OpenStruct.new(uid:      "uid",
                     provider: "provider",
                     info:     auth_info,
                     extra:    auth_extra)
    end
    let(:auth_info) { OpenStruct.new(email: email, name: name) }
    let(:auth_extra) { OpenStruct.new(raw_info: {}) }

    context "when Auth0 login enabled" do
      before { Setting["feature.auth0_login"] = true }
      after { Setting["feature.auth0_login"] = false }

      it "builds new user with data from auth" do
        user = User.first_or_initialize_for_oauth(auth)
        expect(user.email).to eq email
        expect(user.oauth_email).to eq email
        expect(user.username).to eq name
        expect(user.terms_of_service).to be_truthy
        expect(user.instance_variable_get("@skip_confirmation_notification")).to be_truthy
      end

      context "with username not available in Auth0 app_metadata" do
        it "uses Name as a username" do
          user = User.first_or_initialize_for_oauth(auth)
          expect(user.username).to eq name
        end
      end

      context "with username is available in Auth0 app_metadata" do
        let(:auth_extra) do
          OpenStruct.new(raw_info:
                           {
                             "#{ENV["AUTH0_METADATA_NAMESPACE"]}app_metadata" => {
                               username: username
                             }.stringify_keys
                           }
          )
        end
        let(:username) { "auth0_username" }

        it "uses username from Auth0" do
          user = User.first_or_initialize_for_oauth(auth)
          expect(user.username).to eq username
        end
      end

      context "when user has already been confirmed via Auth0" do
        let(:auth_extra) { OpenStruct.new(raw_info: { email_verified: 1 }) }

        it "confirms the user" do
          user = User.first_or_initialize_for_oauth(auth)
          expect(user.confirmed?).to be_truthy
        end
      end

      context "when user has not yet been confirmed via Auth0" do
        it "does not confirm the user" do
          user = User.first_or_initialize_for_oauth(auth)
          expect(user.confirmed?).to be_falsey
        end
      end
    end

    context "when Auth0 login disabled" do
      before { Setting["feature.auth0_login"] = false }

      it "does not skip the email confirmation message" do
        user = User.first_or_initialize_for_oauth(auth)
        expect(user.instance_variable_get("@skip_confirmation_notification")).to be_falsey
      end
    end
  end
end
