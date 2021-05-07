require "rails_helper"

describe ManagementHelper do
  describe "#manager_for_ability" do
    it "returns manager_logged_in" do
      manager = create(:manager).user
      allow(helper).to receive(:manager_logged_in).and_return(manager)
      expect(helper.manager_logged_in).to eq(manager)
    end
  end
end
