require "rails_helper"
require "cancan/matchers"

describe Abilities::Manager do
  subject(:ability) { Ability.new(user) }

  let(:user) { create(:manager).user }
  let(:administrator) { create(:administrator).user }

  let(:other_user) { create(:user) }
  let(:oecd_representative) { create(:oecd_representative).user }

  context "when non-standard user" do
    before { allow(other_user).to receive(:standard_user?).and_return(false) }

    it { should_not be_able_to(:promote_to_oecd_representative, other_user) }
    it { should_not be_able_to(:promote_to_oecd_representative, oecd_representative) }
    it { should_not be_able_to(:promote_to_oecd_representative, administrator) }
  end

  context "when standard user" do
    before { allow(other_user).to receive(:standard_user?).and_return(true) }

    it { should be_able_to(:promote_to_oecd_representative, other_user) }
    it { should_not be_able_to(:promote_to_oecd_representative, build(:user)) }
  end
end
