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
    it { should_not be_able_to(:comment_as_moderator, own_process) }
    it { should_not be_able_to(:comment_as_administrator, own_process) }
    it { should_not be_able_to(:manage, other_user_process) }

    it { should be_able_to(:manage, own_process_draft) }
    it { should_not be_able_to(:comment_as_moderator, own_process_draft) }
    it { should_not be_able_to(:comment_as_administrator, own_process_draft) }
    it { should_not be_able_to(:manage, other_user_process_draft) }

    it { should be_able_to(:manage, own_process_question) }
    it { should_not be_able_to(:comment_as_moderator, own_process_question) }
    it { should_not be_able_to(:comment_as_administrator, own_process_question) }
    it { should_not be_able_to(:manage, other_user_process_question) }

    it { should be_able_to(:manage, own_process_proposal) }
    it { should_not be_able_to(:comment_as_moderator, own_process_proposal) }
    it { should_not be_able_to(:comment_as_administrator, own_process_proposal) }
    it { should_not be_able_to(:manage, other_user_process_proposal) }
  end

  context "Content moderation" do
    let(:date) { 2.days.ago }
    let(:own_process) { create(:legislation_process, author: user) }
    let(:own_process2) { create(:legislation_process, author: user) }
    let(:managed_legislation_question) { create(:legislation_question, process: own_process) }
    let(:managed_legislation_proposal) { create(:legislation_proposal, process: own_process2) }
    let(:question_comment) { create(:comment, commentable: managed_legislation_question) }
    let(:proposal_comment) { create(:comment, commentable: managed_legislation_proposal) }
    let(:annotation_comment) do
      create(:legislation_annotation,
             draft_version: create(:legislation_draft_version, process: create(:legislation_process, author: user))
      ).comments.last
    end
    let(:own_comment) { create(:comment, commentable: managed_legislation_question, author: user) }
    let(:other_process_comment) { create(:comment) }

    context "when comment has not been hidden or ignored yet" do
      it { should be_able_to(:hide, question_comment) }
      it { should be_able_to(:hide, proposal_comment) }
      it { should be_able_to(:hide, annotation_comment) }
      it { should_not be_able_to(:hide, other_process_comment) }
      it { should_not be_able_to(:hide, own_comment) }
      it { should be_able_to(:ignore_flag, question_comment) }
      it { should be_able_to(:ignore_flag, proposal_comment) }
      it { should be_able_to(:ignore_flag, annotation_comment) }
      it { should_not be_able_to(:ignore_flag, other_process_comment) }
      it { should_not be_able_to(:ignore_flag, own_comment) }
      it { should be_able_to(:moderate, question_comment) }
      it { should be_able_to(:moderate, proposal_comment) }
      it { should be_able_to(:moderate, annotation_comment) }
      it { should_not be_able_to(:moderate, other_process_comment) }
      it { should_not be_able_to(:moderate, own_comment) }
    end

    context "when comment has already been hidden" do
      let(:question_comment) { create(:comment, commentable: managed_legislation_question, hidden_at: date) }
      let(:proposal_comment) { create(:comment, commentable: managed_legislation_proposal, hidden_at: date) }
      let(:annotation_comment) do
        create(:legislation_annotation,
               draft_version: create(:legislation_draft_version, process: create(:legislation_process, author: user))
        ).comments.last
      end
      let(:other_process_comment) { create(:comment, hidden_at: date) }
      let(:own_comment) { create(:comment, commentable: managed_legislation_question, author: user, hidden_at: date) }

      before do
        annotation_comment.update(hidden_at: date)
      end

      it { should_not be_able_to(:hide, question_comment) }
      it { should_not be_able_to(:hide, proposal_comment) }
      it { should_not be_able_to(:hide, annotation_comment) }
      it { should_not be_able_to(:hide, other_process_comment) }
      it { should_not be_able_to(:hide, own_comment) }
      it { should_not be_able_to(:ignore_flag, question_comment) }
      it { should_not be_able_to(:ignore_flag, proposal_comment) }
      it { should_not be_able_to(:ignore_flag, annotation_comment) }
      it { should_not be_able_to(:ignore_flag, other_process_comment) }
      it { should_not be_able_to(:ignore_flag, own_comment) }
      it { should be_able_to(:moderate, question_comment) }
      it { should be_able_to(:moderate, proposal_comment) }
      it { should be_able_to(:moderate, annotation_comment) }
      it { should_not be_able_to(:moderate, other_process_comment) }
      it { should_not be_able_to(:moderate, own_comment) }
    end

    context "when comment has already been ignored" do
      let(:question_comment) { create(:comment, commentable: managed_legislation_question, ignored_flag_at: date) }
      let(:proposal_comment) { create(:comment, commentable: managed_legislation_proposal, ignored_flag_at: date) }
      let(:annotation_comment) do
        create(:legislation_annotation,
               draft_version: create(:legislation_draft_version, process: create(:legislation_process, author: user))
        ).comments.last
      end
      let(:other_process_comment) { create(:comment, ignored_flag_at: date) }
      let(:own_comment) do
        create(:comment, commentable: managed_legislation_question, author: user, ignored_flag_at: date)
      end

      before do
        annotation_comment.update(ignored_flag_at: date)
      end

      it { should_not be_able_to(:ignore_flag, question_comment) }
      it { should_not be_able_to(:ignore_flag, proposal_comment) }
      it { should_not be_able_to(:ignore_flag, annotation_comment) }
      it { should_not be_able_to(:ignore_flag, other_process_comment) }
      it { should_not be_able_to(:ignore_flag, own_comment) }
    end

    context "when Legislation::Proposal" do
      let(:own_process) { create(:legislation_process, author: user) }
      let(:managed_legislation_proposal) { create(:legislation_proposal, process: own_process) }
      let(:other_legislation_proposal) { create(:legislation_proposal) }
      let(:own_legislation_proposal) { create(:legislation_proposal, process: own_process, author: user) }

      context "when not been hidden or ignored yet" do
        it { should be_able_to(:hide, managed_legislation_proposal) }
        it { should_not be_able_to(:hide, other_legislation_proposal) }
        it { should_not be_able_to(:hide, own_legislation_proposal) }
        it { should be_able_to(:ignore_flag, managed_legislation_proposal) }
        it { should_not be_able_to(:ignore_flag, other_legislation_proposal) }
        it { should_not be_able_to(:ignore_flag, own_legislation_proposal) }
        it { should be_able_to(:moderate, managed_legislation_proposal) }
        it { should_not be_able_to(:moderate, other_legislation_proposal) }
        it { should_not be_able_to(:moderate, own_legislation_proposal) }
      end

      context "when has already been hidden" do
        let(:managed_legislation_proposal)do
          create(:legislation_proposal, process: own_process, hidden_at: date)
        end
        let(:other_legislation_proposal) { create(:legislation_proposal, hidden_at: date) }
        let(:own_legislation_proposal) do
          create(:legislation_proposal, process: own_process, author: user, hidden_at: date)
        end

        it { should_not be_able_to(:hide, managed_legislation_proposal) }
        it { should_not be_able_to(:hide, other_legislation_proposal) }
        it { should_not be_able_to(:hide, own_legislation_proposal) }
        it { should_not be_able_to(:ignore_flag, managed_legislation_proposal) }
        it { should_not be_able_to(:ignore_flag, other_legislation_proposal) }
        it { should_not be_able_to(:ignore_flag, own_legislation_proposal) }
        it { should be_able_to(:moderate, managed_legislation_proposal) }
        it { should_not be_able_to(:moderate, other_legislation_proposal) }
        it { should_not be_able_to(:moderate, own_legislation_proposal) }
      end

      context "when has already been ignored" do
        let(:managed_legislation_proposal) do
          create(:legislation_proposal, process: own_process, ignored_flag_at: date)
        end
        let(:other_legislation_proposal) { create(:legislation_proposal, ignored_flag_at: date) }
        let(:own_legislation_proposal) do
          create(:legislation_proposal, process: own_process, author: user, ignored_flag_at: date)
        end

        it { should be_able_to(:hide, managed_legislation_proposal) }
        it { should_not be_able_to(:hide, other_legislation_proposal) }
        it { should_not be_able_to(:hide, own_legislation_proposal) }
        it { should_not be_able_to(:ignore_flag, managed_legislation_proposal) }
        it { should_not be_able_to(:ignore_flag, other_legislation_proposal) }
        it { should_not be_able_to(:ignore_flag, own_legislation_proposal) }
        it { should be_able_to(:moderate, managed_legislation_proposal) }
        it { should_not be_able_to(:moderate, other_legislation_proposal) }
        it { should_not be_able_to(:moderate, own_legislation_proposal) }
      end
    end
  end
end
