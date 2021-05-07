require "rails_helper"

describe AdminHelper do
  describe "#admin_submit_action" do
    it "returns new when the the resource has not been persisted" do
      poll = build(:poll)
      expect(admin_submit_action(poll)).to eq("new")
    end

    it "returns edit when the the resource has been persisted" do
      poll = create(:poll)
      expect(admin_submit_action(poll)).to eq("edit")
    end

    describe "#user_roles" do
      context "when user is an OECD Representative" do
        it "returns :oecd_representative in roles" do
          user = create(:oecd_representative).user
          expect(helper.user_roles(user)).to eq %i[oecd_representative]
        end
      end
    end
  end
end
