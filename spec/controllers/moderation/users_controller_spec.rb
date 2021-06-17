require "rails_helper"

describe Moderation::UsersController do
  context "when signed in as a moderator" do
    before { sign_in create(:moderator).user }

    describe "PUT hide_in_moderation_screen" do
      it "keeps query parameters while using protected redirects" do
        user = create(:user, email: "user@consul.dev")

        get :hide_in_moderation_screen, params: { id: user, name_or_email: "user@consul.dev", host: "evil.dev" }

        expect(response).to redirect_to "/moderation/users?name_or_email=user%40consul.dev"
      end
    end
  end

  context "when signed in as a manager" do
    before { sign_in create(:manager).user }

    describe "PUT hide_in_moderation_screen" do
      it "keeps query parameters while using protected redirects" do
        user = create(:user, email: "user@consul.dev")

        get :hide_in_moderation_screen, params: { id: user, name_or_email: "user@consul.dev", host: "evil.dev" }

        expect(response).to redirect_to "/moderation/users?name_or_email=user%40consul.dev"
      end
    end
  end

  context "when signed in as a admin" do
    before { sign_in create(:administrator).user }

    describe "PUT hide_in_moderation_screen" do
      it "keeps query parameters while using protected redirects" do
        user = create(:user, email: "user@consul.dev")

        get :hide_in_moderation_screen, params: { id: user, name_or_email: "user@consul.dev", host: "evil.dev" }

        expect(response).to redirect_to "/moderation/users?name_or_email=user%40consul.dev"
      end
    end
  end
end
