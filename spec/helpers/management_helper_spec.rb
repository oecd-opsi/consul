require "rails_helper"

describe ManagementHelper do
  describe "#manager_for_ability" do
    it "returns manager_logged_in" do
      manager = create(:manager).user
      allow(helper).to receive(:manager_logged_in).and_return(manager)
      expect(helper.manager_logged_in).to eq(manager)
    end
  end

  describe "#permissions_for" do
    context "when standard user" do
      let(:user) { create(:user) }
      it "returns default permissions" do
        expect(helper.permissions_for(user)).to eq(described_class::DEFAULT_PERMISSIONS)
      end
    end

    context "when OECD Representative" do
      let(:user) { create(:oecd_representative).user }
      it "returns extended permissions" do
        expected_permissions = described_class::DEFAULT_PERMISSIONS + described_class::OECD_REPRESENTATIVE_PERMISSIONS
        expect(helper.permissions_for(user)).to eq(expected_permissions)
      end
    end
  end
end
