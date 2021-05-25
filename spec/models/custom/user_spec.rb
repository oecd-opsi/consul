require "rails_helper"

describe User do
  let(:user) { create(:user) }

  describe "display_name validations" do
    let(:user) { create(:user, display_name: nil) }

    context "when validate_display_name not set" do
      before { user.save }

      it "is valid without display name" do
        expect(user).to be_persisted
        expect(user.display_name).to be_nil
      end

      it "is is valid with display name" do
        user.update!(display_name: Faker::Name.name)
        expect(user).to be_valid
        expect(user.errors[:display_name]).to be_empty
      end
    end

    context "when validate_display_name set" do
      it "is not valid without display name" do
        user.update!(display_name: nil, validate_display_name: true)
        expect(user).not_to be_valid
        expect(user.errors[:display_name]).not_to be_empty
      end

      it "is is valid with display name" do
        user.update!(display_name: Faker::Name.name, validate_display_name: true)
        expect(user).to be_valid
        expect(user.errors[:display_name]).to be_empty
      end
    end
  end

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
        expect(user.display_name).to eq name
        expect(user.terms_of_service).to be_truthy
        expect(user.instance_variable_get("@skip_confirmation_notification")).to be_truthy
      end

      context "with username not available in Auth0 app_metadata" do
        context "when username is present in auth info" do
          let(:auth_info) { OpenStruct.new(email: email, username: "username") }

          it "uses username from auth.info as a username" do
            user = User.first_or_initialize_for_oauth(auth)
            expect(user.username).to eq auth_info.username
          end

          it "uses username from auth.info as a display_name" do
            user = User.first_or_initialize_for_oauth(auth)
            expect(user.display_name).to eq auth_info.username
          end
        end

        context "when nickname is present in auth info" do
          let(:auth_info) { OpenStruct.new(email: email, nickname: "nickname") }

          it "uses username from auth.info as a username" do
            user = User.first_or_initialize_for_oauth(auth)
            expect(user.username).to eq auth_info.nickname
          end

          it "uses username from auth.info as a display_name" do
            user = User.first_or_initialize_for_oauth(auth)
            expect(user.display_name).to eq auth_info.nickname
          end
        end

        context "when only name is present in auth info" do
          let(:auth_info) { OpenStruct.new(email: email, name: name) }

          it "uses name as a username" do
            user = User.first_or_initialize_for_oauth(auth)
            expect(user.username).to eq name
          end

          it "uses name from auth.info as a display_name" do
            user = User.first_or_initialize_for_oauth(auth)
            expect(user.display_name).to eq name
          end
        end
      end

      context "with name not available in info, but available in raw_info" do
        let(:auth_info) { OpenStruct.new(email: email) }
        let(:auth_extra) { OpenStruct.new(raw_info: { name: name }) }

        it "uses uid as a username" do
          user = User.first_or_initialize_for_oauth(auth)
          expect(user.username).to eq auth.uid
        end

        it "uses name from extra as display_name" do
          user = User.first_or_initialize_for_oauth(auth)
          expect(user.display_name).to eq name
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

  describe "oecd_representative?" do
    let(:user) { build(:user) }

    it "is false when the user is not an OECD representative" do
      expect(user.oecd_representative?).to be_falsey
    end

    it "is true when the user is an admin" do
      user.save!
      create(:oecd_representative, user: user)
      expect(user.oecd_representative?).to be_truthy
    end
  end

  describe "standard_user?" do
    let(:user) { build(:user) }

    context "when does not have any additional roles" do
      it "is true" do
        expect(user).to be_standard_user
      end
    end

    context "when is an admin" do
      let(:user) { create(:administrator).user }
      it "is false" do
        expect(user).not_to be_standard_user
      end
    end

    context "when is a moderator" do
      let(:user) { create(:moderator).user }
      it "is false" do
        expect(user).not_to be_standard_user
      end
    end

    context "when is a valuator" do
      let(:user) { create(:valuator).user }
      it "is false" do
        expect(user).not_to be_standard_user
      end
    end

    context "when is a manager" do
      let(:user) { create(:manager).user }
      it "is false" do
        expect(user).not_to be_standard_user
      end
    end

    context "when is a poll officer" do
      let(:user) { create(:poll_officer).user }
      it "is false" do
        expect(user).not_to be_standard_user
      end
    end

    context "when is a organization" do
      let(:user) { create(:organization).user }
      it "is false" do
        expect(user).not_to be_standard_user
      end
    end

    context "when is a OECD Representative" do
      let(:user) { create(:oecd_representative).user }
      it "is false" do
        expect(user).not_to be_standard_user
      end
    end
  end

  describe "#name" do
    it "is the display_name when the user is not an organization" do
      expect(subject.name).to eq(subject.display_name)
    end

    it "is the organization when the user is not an organization" do
      organization = create(:organization, user: subject)
      expect(subject.name).to eq(organization.name)
    end
  end

  describe "#display_name_required?" do
    let(:user) { build(:user) }

    context "when username_required? and validate_display_name" do
      it "is truthy" do
        allow(user).to receive(:username_required?).and_return(true)
        allow(user).to receive(:validate_display_name).and_return(true)
        expect(user).to be_display_name_required
      end
    end

    context "when username_required? but validate_display_name is false" do
      it "is falsey" do
        allow(user).to receive(:username_required?).and_return(true)
        allow(user).to receive(:validate_display_name).and_return(false)
        expect(user).not_to be_display_name_required
      end
    end

    context "when not username_required? and validate_display_name is true" do
      it "is falsey" do
        allow(user).to receive(:username_required?).and_return(false)
        allow(user).to receive(:validate_display_name).and_return(true)
        expect(user).not_to be_display_name_required
      end
    end

    context "when both username_required? and validate_display_name are false" do
      it "is falsey" do
        allow(user).to receive(:username_required?).and_return(false)
        allow(user).to receive(:validate_display_name).and_return(false)
        expect(user).not_to be_display_name_required
      end
    end
  end

  describe "#erase" do
    let(:reason) { Faker::Lorem.sentence }
    let(:user) do
      create(:user,
             username:                 "username",
             display_name:             Faker::Name.name,
             email:                    Faker::Internet.email,
             unconfirmed_email:        Faker::Internet.email,
             phone_number:             Faker::PhoneNumber.phone_number,
             confirmed_phone:          Faker::PhoneNumber.phone_number,
             confirmation_token:       "confirmation_token",
             reset_password_token:     "reset_password_token",
             email_verification_token: "email_verification_token",
             password:                 "ValidPassword123!",
             password_confirmation:    "ValidPassword123!",
             unconfirmed_phone:        Faker::PhoneNumber.phone_number)
    end
    before do
      user.erase(reason)
      user.reload
    end

    it "sets erased_at" do
      expect(user.erased_at).not_to be_nil
    end

    it "saves erase_reason" do
      expect(user.erase_reason).to eq(reason)
    end

    it "erases username" do
      expect(user.username).to be_nil
    end

    it "erases display_name" do
      expect(user.display_name).to be_nil
    end

    it "erases email" do
      expect(user.email).to be_nil
    end

    it "erases unconfirmed_email" do
      expect(user.unconfirmed_email).to be_nil
    end

    it "erases phone_number" do
      expect(user.phone_number).to be_nil
    end

    it "erases encrypted_password" do
      expect(user.encrypted_password).to eq("")
    end

    it "erases confirmation_token" do
      expect(user.confirmation_token).to be_nil
    end

    it "erases reset_password_token" do
      expect(user.reset_password_token).to be_nil
    end

    it "erases email_verification_token" do
      expect(user.email_verification_token).to be_nil
    end

    it "erases confirmed_phone" do
      expect(user.confirmed_phone).to be_nil
    end

    it "erases unconfirmed_phone" do
      expect(user.unconfirmed_phone).to be_nil
    end
  end

  describe "self.search" do
    it "find users by email" do
      user1 = create(:user, email: "larry@consul.dev")
      create(:user, email: "bird@consul.dev")
      search = User.search("larry@consul.dev")

      expect(search).to eq [user1]
    end

    it "find users by display_name" do
      user1 = create(:user, display_name: "Larry Bird")
      create(:user, display_name: "Robert Parish")
      search = User.search("larry")

      expect(search).to eq [user1]
    end

    it "returns no results if no search term provided" do
      expect(User.search("    ")).to be_empty
    end
  end
end
