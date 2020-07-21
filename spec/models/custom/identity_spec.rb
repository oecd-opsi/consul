require "rails_helper"

describe Identity do
  describe "synchronize_or_create_from_oauth" do
    let(:auth) { OpenStruct.new(uid: "uid", provider: "provider") }

    context "identity does not exist" do
      it "creates new identity" do
        expect { Identity.synchronize_or_create_from_oauth(auth) }
          .to change { Identity.count }.by(1)
      end
    end

    context "with identity and user" do
      let(:identity) { create(:identity, uid: auth.uid, provider: auth.provider, user: create(:user)) }

      before do
        identity
      end

      it "does not create new identity" do
        expect { Identity.synchronize_or_create_from_oauth(auth) }
          .not_to change { Identity.count }
      end

      it "passes auth details to user" do
        expect_any_instance_of(User).to receive(:synchronize_with_auth!)
        Identity.synchronize_or_create_from_oauth(auth)
      end
    end
  end
end
