require "rails_helper"
require "cancan/matchers"

describe Abilities::OecdRepresentative do
  subject(:ability) { Ability.new(user) }

  let(:user) { create(:oecd_representative).user }

  context "when Legislation" do
    it { should be_able_to(:manage, ::Legislation::Process) }
    it { should be_able_to(:manage, ::Legislation::DraftVersion) }
    it { should be_able_to(:manage, ::Legislation::Question) }
    it { should be_able_to(:manage, ::Legislation::Proposal) }
  end
end
