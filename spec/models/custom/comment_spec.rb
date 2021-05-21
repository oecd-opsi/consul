require "rails_helper"

describe Comment do
  let(:comment) { build(:comment) }

  describe "for_process" do
    let(:process) { create(:legislation_process) }
    let!(:other_process) { create(:legislation_process) }
    let!(:question_comment) { create(:comment, commentable: create(:legislation_question, process: process)) }
    let!(:proposal_comment) { create(:comment, commentable: create(:legislation_question, process: process)) }
    let!(:annotation_comment) do
      create(
        :legislation_annotation,
        draft_version: create(:legislation_draft_version, process: process)
      ).comments.last
    end
    let!(:other_comment) { create(:comment) }
    let!(:other_question_comment) do
      create(:comment, commentable: create(:legislation_question, process: other_process))
    end

    context "when there are different types of comments" do
      it "returns all comments of process" do
        result = Comment.for_processes(process)
        expect(result.size).to eq 3
        expect(result).to include(question_comment)
        expect(result).to include(proposal_comment)
        expect(result).to include(annotation_comment)
        expect(result).not_to include(other_comment)
      end
    end

    context "when there is just one type of comments" do
      it "returns all comments of process" do
        result = Comment.for_processes(other_process)
        expect(result.size).to eq 1
        expect(result).to include(other_question_comment)
        expect(result).not_to include(other_comment)
      end
    end

    context "when there are no comments" do
      it "returns empty array" do
        result = Comment.for_processes(create(:legislation_process))
        expect(result).to be_empty
      end
    end
  end

  describe "commentable_process" do
    context "when there is a process assigned to the commentable" do
      let(:process) { create(:legislation_process) }
      let(:comment) { create(:comment, commentable: create(:legislation_question, process: process)) }

      it "returns process from commentable" do
        expect(comment.commentable_process).to eq process
      end
    end

    context "when there is a process assigned to the commentable" do
      let(:comment) { create(:budget_investment_comment) }

      it "returns nil" do
        expect(comment.commentable_process).to be_nil
      end
    end
  end

  describe "commentable_process?" do
    context "when there is a process assigned to the commentable" do
      let(:process) { create(:legislation_process) }
      let(:comment) { create(:comment, commentable: create(:legislation_question, process: process)) }

      it "returns true " do
        expect(comment).to be_commentable_process
      end
    end

    context "when there is a process assigned to the commentable" do
      let(:comment) { create(:budget_investment_comment) }

      it "returns false " do
        expect(comment).not_to be_commentable_process
      end
    end
  end

  describe "commentable_process_id" do
    context "when there is a process assigned to the commentable" do
      let(:process) { create(:legislation_process) }
      let(:comment) { create(:comment, commentable: create(:legislation_question, process: process)) }

      it "returns process id from commentable" do
        expect(comment.commentable_process_id).to eq process.id
      end
    end

    context "when there is a process assigned to the commentable" do
      let(:comment) { create(:budget_investment_comment) }

      it "returns nil" do
        expect(comment.commentable_process_id).to be_nil
      end
    end
  end

  describe "commentable_process_title" do
    context "when there is a process assigned to the commentable" do
      let(:process) { create(:legislation_process) }
      let(:comment) { create(:comment, commentable: create(:legislation_question, process: process)) }

      it "returns process title from commentable" do
        expect(comment.commentable_process_title).to eq process.title
      end
    end

    context "when there is a process assigned to the commentable" do
      let(:comment) { create(:budget_investment_comment) }

      it "returns nil" do
        expect(comment.commentable_process_title).to be_nil
      end
    end
  end
end
