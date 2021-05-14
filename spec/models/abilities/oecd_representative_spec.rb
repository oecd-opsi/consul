require "rails_helper"
require "cancan/matchers"

describe Abilities::OecdRepresentative do
  subject(:ability) { Ability.new(user) }

  let(:user) { create(:oecd_representative).user }

  context "when Legislation" do
    let(:own_process) { create(:legislation_process, author: user) }
    let(:other_user_process) { create(:legislation_process) }
    let(:own_process_draft) { create(:legislation_draft_version, process: own_process) }
    let(:other_user_process_draft) { create(:legislation_draft_version, process: other_user_process) }
    let(:own_process_question) { create(:legislation_question, process: own_process) }
    let(:other_user_process_question) { create(:legislation_question, process: other_user_process) }
    let(:own_process_proposal) { create(:legislation_proposal, process: own_process) }
    let(:other_user_process_proposal) { create(:legislation_proposal, process: other_user_process) }

    it { should be_able_to(:create, ::Legislation::Process) }
    it { should be_able_to(:manage, own_process) }
    it { should_not be_able_to(:manage, other_user_process) }

    it { should be_able_to(:manage, own_process_draft) }
    it { should_not be_able_to(:manage, other_user_process_draft) }

    it { should be_able_to(:manage, own_process_question) }
    it { should_not be_able_to(:manage, other_user_process_question) }

    it { should be_able_to(:manage, own_process_proposal) }
    it { should_not be_able_to(:manage, other_user_process_proposal) }
  end
end
