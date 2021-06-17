require "rails_helper"
require "cancan/matchers"

describe Abilities::Manager do
  subject(:ability) { Ability.new(user) }

  let(:user) { create(:manager).user }
  let(:administrator) { create(:administrator).user }

  let(:other_user) { create(:user) }
  let(:oecd_representative) { create(:oecd_representative).user }

  let(:debate) { create(:debate) }
  let(:comment) { create(:comment) }
  let(:proposal) { create(:proposal) }
  let(:legislation_question) { create(:legislation_question) }

  let(:own_debate) { create(:debate, author: user) }
  let(:own_comment) { create(:comment, author: user) }
  let(:own_proposal) { create(:proposal, author: user) }

  let(:hidden_debate) { create(:debate, :hidden) }
  let(:hidden_comment) { create(:comment, :hidden) }
  let(:hidden_proposal) { create(:proposal, :hidden) }

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

  it { should be_able_to(:read, OecdRepresentativeRequest) }

  context "with pending OecdRepresentativeRequest from standard user" do
    let(:oecd_representative_request) { create(:oecd_representative_request, status: :pending) }
    it { should be_able_to(:accept, oecd_representative_request) }
    it { should be_able_to(:reject, oecd_representative_request) }
  end

  context "with accepted OecdRepresentativeRequest" do
    let(:oecd_representative_request) { create(:oecd_representative_request, status: :accepted) }
    it { should_not be_able_to(:accept, oecd_representative_request) }
    it { should_not be_able_to(:reject, oecd_representative_request) }
  end

  context "with rejected OecdRepresentativeRequest" do
    let(:oecd_representative_request) { create(:oecd_representative_request, status: :rejected) }
    it { should_not be_able_to(:accept, oecd_representative_request) }
    it { should_not be_able_to(:reject, oecd_representative_request) }
  end

  context "with pending OecdRepresentativeRequest from already upgraded user" do
    let(:user) { create(:oecd_representative).user }
    let(:oecd_representative_request) { create(:oecd_representative_request, status: :pending, user: user) }
    it { should_not be_able_to(:accept, oecd_representative_request) }
    it { should_not be_able_to(:reject, oecd_representative_request) }
  end

  describe "hiding, reviewing and restoring" do
    let(:ignored_comment)  { create(:comment, :with_ignored_flag) }
    let(:ignored_debate)   { create(:debate,  :with_ignored_flag) }
    let(:ignored_proposal) { create(:proposal, :with_ignored_flag) }

    it { should be_able_to(:hide, comment) }
    it { should be_able_to(:hide_in_moderation_screen, comment) }
    it { should_not be_able_to(:hide, hidden_comment) }
    it { should_not be_able_to(:hide, own_comment) }

    it { should be_able_to(:moderate, comment) }
    it { should_not be_able_to(:moderate, own_comment) }

    it { should be_able_to(:hide, debate) }
    it { should be_able_to(:hide_in_moderation_screen, debate) }
    it { should_not be_able_to(:hide, hidden_debate) }
    it { should_not be_able_to(:hide, own_debate) }

    it { should be_able_to(:hide, proposal) }
    it { should be_able_to(:hide_in_moderation_screen, proposal) }
    it { should be_able_to(:hide, own_proposal) }
    it { should_not be_able_to(:hide, hidden_proposal) }

    it { should be_able_to(:ignore_flag, comment) }
    it { should_not be_able_to(:ignore_flag, hidden_comment) }
    it { should_not be_able_to(:ignore_flag, ignored_comment) }
    it { should_not be_able_to(:ignore_flag, own_comment) }

    it { should be_able_to(:ignore_flag, debate) }
    it { should_not be_able_to(:ignore_flag, hidden_debate) }
    it { should_not be_able_to(:ignore_flag, ignored_debate) }
    it { should_not be_able_to(:ignore_flag, own_debate) }

    it { should be_able_to(:moderate, debate) }
    it { should_not be_able_to(:moderate, own_debate) }

    it { should be_able_to(:ignore_flag, proposal) }
    it { should_not be_able_to(:ignore_flag, hidden_proposal) }
    it { should_not be_able_to(:ignore_flag, ignored_proposal) }
    it { should_not be_able_to(:ignore_flag, own_proposal) }

    it { should be_able_to(:moderate, proposal) }
    it { should be_able_to(:moderate, own_proposal) }

    it { should_not be_able_to(:hide, user) }
    it { should be_able_to(:hide, other_user) }

    it { should_not be_able_to(:block, user) }
    it { should be_able_to(:block, other_user) }

    it { should_not be_able_to(:restore, comment) }
    it { should_not be_able_to(:restore, debate) }
    it { should_not be_able_to(:restore, proposal) }
    it { should_not be_able_to(:restore, other_user) }

    it { should_not be_able_to(:comment_as_moderator, debate) }
    it { should_not be_able_to(:comment_as_moderator, proposal) }
    it { should_not be_able_to(:comment_as_moderator, legislation_question) }
    it { should_not be_able_to(:comment_as_administrator, debate) }
    it { should_not be_able_to(:comment_as_administrator, proposal) }
    it { should_not be_able_to(:comment_as_administrator, legislation_question) }
  end
end
