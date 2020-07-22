require "rails_helper"

describe Auth0UserUpdater do
  let(:auth0_mock) { double("auth0_client") }
  let(:user) { create(:user) }
  let(:auth0_matching_users_list) { [] }
  let(:identity) { create(:identity, :authenticated_by_password, user: user) }
  let(:login_via_password_id) { identity.uid }
  let(:result) { Auth0UserUpdater.process(user, user_params) }

  before do
    allow(Auth0Client).to receive(:new).and_return(auth0_mock)
    allow(auth0_mock).to receive(:update_user)
    allow(auth0_mock).to receive(:users).and_return(auth0_matching_users_list)
    identity
  end

  context "when updating Email" do
    let(:user_params) { { email: new_email } }

    context "with valid email address given" do
      let(:new_email) { "email@example.com" }

      before { Auth0UserUpdater.process(user, user_params) }

      it "do not sent email update notification" do
        expect(user.instance_variable_get("@skip_confirmation_notification")).to be_truthy
      end

      it "saves new user email in internal DB as unconfirmed" do
        expect(user.reload.unconfirmed_email).to eq(new_email)
      end

      it "updates user email in Auth0 DB" do
        update_params = {
          email:        new_email,
          verify_email: true,
          connection:   "Username-Password-Authentication"
        }
        expect(auth0_mock).to have_received(:update_user).with(login_via_password_id,
                                                               update_params)
      end
    end

    context "with invalid email address given" do
      let(:new_email) { "example.com" }

      before { result }

      it "assigns errors to user email" do
        expect(result.errors).not_to be_empty
        expect(result.errors[:email].size).to eq 1
      end

      it "do not save email" do
        expect(user.reload.unconfirmed_email).not_to eq(new_email)
      end

      it "do not update user email in Auth0 DB" do
        expect(auth0_mock).not_to have_received(:update_user)
      end
    end

    context "with email used by other Auth0 user" do
      let(:new_email) { "email@example.com" }
      let(:auth0_matching_users_list) { [new_email] }

      before { result }

      it "assigns errors to user email" do
        expect(result.errors).not_to be_empty
        expect(result.errors[:email]).to eq [I18n.t("errors.messages.taken")]
      end

      it "do not save email" do
        expect(user.reload.unconfirmed_email).not_to eq(new_email)
      end

      it "do not update user email in Auth0 DB" do
        expect(auth0_mock).not_to have_received(:update_user)
      end
    end

    context "with Auth0 validation error" do
      let(:new_email) { "email@example.com" }

      before do
        allow(auth0_mock).to receive(:update_user).and_raise(Auth0::BadRequest, "Invalid Email")
        result
      end

      it "assigns errors to user email" do
        expect(result.errors).not_to be_empty
        expect(result.errors[:email].size).to eq 1
      end

      it "do not save email" do
        expect(user.reload.unconfirmed_email).not_to eq(new_email)
      end
    end
  end

  context "when updating Password" do
    let(:user_params) { { password: password, password_confirmation: password_confirmation } }

    context "with valid password given" do
      let(:password) { "password123" }
      let(:password_confirmation) { "password123" }

      before { Auth0UserUpdater.process(user, user_params) }

      it "updates user password in Auth0 DB" do
        update_params = {
          password:     password,
          verify_email: false,
          connection:   "Username-Password-Authentication"
        }
        expect(auth0_mock).to have_received(:update_user).with(login_via_password_id,
                                                               update_params)
      end

      context "with invalid password given" do
        let(:password) { "123" }
        let(:password_confirmation) { "password" }

        before { result }

        it "assigns errors to user" do
          expect(result.errors).not_to be_empty
        end

        it "assigns errors to password" do
          expect(result.errors[:password].size).to eq 1
        end

        it "assigns errors to password confirmation" do
          expect(result.errors[:password_confirmation].size).to eq 1
        end

        it "do not update user email in Auth0 DB" do
          expect(auth0_mock).not_to have_received(:update_user)
        end
      end

      context "with Auth0 validation error" do
        let(:password) { "password123" }
        let(:password_confirmation) { "password123" }

        before do
          allow(auth0_mock).to receive(:update_user).and_raise(Auth0::BadRequest, "Invalid Password")
          result
        end

        it "assigns errors to password" do
          expect(result.errors).not_to be_empty
          expect(result.errors[:password].size).to eq 1
        end
      end
    end
  end
end
