require "rails_helper"

describe Legislation::Process do
  let(:process) { create(:legislation_process) }

  it_behaves_like "acts as paranoid", :legislation_process
  it_behaves_like "globalizable", :legislation_process

  it "is valid" do
    expect(process).to be_valid
  end

  describe "dates validations" do
    it "is invalid if debate_start_date is present but debate_end_date is not" do
      process = build(:legislation_process, debate_start_date: Date.current, debate_end_date: "")
      expect(process).to be_invalid
      expect(process.errors.messages[:debate_end_date]).to include("can't be blank")
    end

    it "is invalid if debate_end_date is present but debate_start_date is not" do
      process = build(:legislation_process, debate_start_date: nil, debate_end_date: Date.current)
      expect(process).to be_invalid
      expect(process.errors.messages[:debate_start_date]).to include("can't be blank")
    end

    it "is invalid if allegations_start_date is present but debate_end_date is not" do
      process = build(:legislation_process, allegations_start_date: Date.current,
                      allegations_end_date:                         "")
      expect(process).to be_invalid
      expect(process.errors.messages[:allegations_end_date]).to include("can't be blank")
    end

    it "is invalid if debate_end_date is present but allegations_start_date is not" do
      process = build(:legislation_process, allegations_start_date: nil,
                      allegations_end_date:                         Date.current)
      expect(process).to be_invalid
      expect(process.errors.messages[:allegations_start_date]).to include("can't be blank")
    end
  end

  describe "date ranges validations" do
    it "is invalid if end_date is before start_date" do
      process = build(:legislation_process, start_date: Date.current,
                      end_date:                         Date.current - 1.day)
      expect(process).to be_invalid
      expect(process.errors.messages[:end_date]).to include("must be on or after the start date")
    end

    it "is valid if end_date is the same as start_date" do
      process = build(:legislation_process, start_date: Date.current - 1.day,
                      end_date:                         Date.current - 1.day)
      expect(process).to be_valid
    end

    it "is valid if debate_end_date is the same as debate_start_date" do
      process = build(:legislation_process, debate_start_date: Date.current - 1.day,
                      debate_end_date:                         Date.current - 1.day)
      expect(process).to be_valid
    end

    it "is invalid if debate_end_date is before debate_start_date" do
      process = build(:legislation_process, debate_start_date: Date.current,
                      debate_end_date:                         Date.current - 1.day)
      expect(process).to be_invalid
      expect(process.errors.messages[:debate_end_date])
        .to include("must be on or after the debate start date")
    end

    it "is valid if draft_end_date is the same as draft_start_date" do
      process = build(:legislation_process, draft_start_date: Date.current - 1.day,
                      draft_end_date:                         Date.current - 1.day)
      expect(process).to be_valid
    end

    it "is invalid if draft_end_date is before draft_start_date" do
      process = build(:legislation_process, draft_start_date: Date.current,
                      draft_end_date:                         Date.current - 1.day)
      expect(process).to be_invalid
      expect(process.errors.messages[:draft_end_date])
        .to include("must be on or after the draft start date")
    end

    it "is invalid if allegations_end_date is before allegations_start_date" do
      process = build(:legislation_process, allegations_start_date: Date.current,
                      allegations_end_date:                         Date.current - 1.day)
      expect(process).to be_invalid
      expect(process.errors.messages[:allegations_end_date])
        .to include("must be on or after the comments start date")
    end

    it "is valid if allegations_end_date is the same as allegations_start_date" do
      process = build(:legislation_process, allegations_start_date: Date.current - 1.day,
                      allegations_end_date:                         Date.current - 1.day)
      expect(process).to be_valid
    end
  end

  describe "filter scopes" do
    describe "open and past filters" do
      let!(:process_1) do
        create(:legislation_process, start_date: Date.current - 2.days, end_date: Date.current + 1.day)
      end

      let!(:process_2) do
        create(:legislation_process, start_date: Date.current + 1.day, end_date: Date.current + 3.days)
      end

      let!(:process_3) do
        create(:legislation_process, start_date: Date.current - 4.days, end_date: Date.current - 3.days)
      end

      it "filters open" do
        open_processes = ::Legislation::Process.open

        expect(open_processes).to eq [process_1]
        expect(open_processes).not_to include [process_2]
      end

      it "filters past" do
        past_processes = ::Legislation::Process.past

        expect(past_processes).to eq [process_3]
      end
    end

    it "filters draft phase" do
      process_before_draft = create(
        :legislation_process,
        draft_start_date: Date.current - 3.days,
        draft_end_date:   Date.current - 2.days
      )

      process_with_draft_disabled = create(
        :legislation_process,
        draft_start_date:    Date.current - 2.days,
        draft_end_date:      Date.current + 2.days,
        draft_phase_enabled: false
      )

      process_with_draft_enabled = create(
        :legislation_process,
        draft_start_date:    Date.current - 2.days,
        draft_end_date:      Date.current + 2.days,
        draft_phase_enabled: true
      )

      process_with_draft_only_today = create(
        :legislation_process,
        draft_start_date:    Date.current,
        draft_end_date:      Date.current,
        draft_phase_enabled: true
      )

      processes_not_in_draft = ::Legislation::Process.not_in_draft

      expect(processes_not_in_draft).to match_array [process_before_draft, process_with_draft_disabled]
      expect(processes_not_in_draft).not_to include(process_with_draft_enabled)
      expect(processes_not_in_draft).not_to include(process_with_draft_only_today)
    end
  end

  describe "#status" do
    it "detects planned phase" do
      process.update!(start_date: Date.current + 2.days)
      expect(process.status).to eq(:planned)
    end

    it "detects closed phase" do
      process.update!(end_date: Date.current - 2.days)
      expect(process.status).to eq(:closed)
    end

    it "detects open phase" do
      expect(process.status).to eq(:open)
    end
  end

  describe "Header colors" do
    it "valid format colors" do
      process1 = create(:legislation_process, background_color: "123", font_color: "#fff")
      process2 = create(:legislation_process, background_color: "#fff", font_color: "123")
      process3 = create(:legislation_process, background_color: "", font_color: "")
      process4 = create(:legislation_process, background_color: "#abf123", font_color: "fff123")
      expect(process1).to be_valid
      expect(process2).to be_valid
      expect(process3).to be_valid
      expect(process4).to be_valid
    end

    it "invalid format colors" do
      expect do
        create(:legislation_process, background_color: "#123ghi", font_color: "#fff")
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Background color is invalid")

      expect do
        create(:legislation_process, background_color: "#fff", font_color: "ggg")
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Font color is invalid")
    end
  end

  describe "milestone_tags" do
    context "without milestone_tags" do
      let(:process) { create(:legislation_process) }

      it "do not have milestone_tags" do
        expect(process.milestone_tag_list).to eq([])
        expect(process.milestone_tags).to eq([])
      end

      it "add a new milestone_tag" do
        process.milestone_tag_list = "tag1,tag2"

        expect(process.milestone_tag_list).to eq(["tag1", "tag2"])
      end
    end

    context "with milestone_tags" do
      let(:process) { create(:legislation_process, :with_milestone_tags) }

      it "has milestone_tags" do
        expect(process.reload.milestone_tag_list.count).to eq(1)
      end
    end
  end

  describe "status_indicator_key" do
    context "when is before start and without draft phase" do
      let(:process) do
        create(:legislation_process,
                             start_date:          2.days.from_now,
                             end_date:            10.days.from_now,
                             draft_phase_enabled: false)
      end

      it "returns :planned" do
        expect(process.status_indicator_key).to eq(:planned)
      end
    end

    context "when is in the draft phase" do
      let(:process) { create(:legislation_process, :in_draft_phase) }

      it "returns :draft" do
        expect(process.status_indicator_key).to eq(:draft)
      end
    end

    context "when it is active" do
      let(:process) { create(:legislation_process, :open) }

      it "returns :open" do
        expect(process.status_indicator_key).to eq(:open)
      end
    end

    context "when it is closed" do
      let(:process) { create(:legislation_process, :past) }

      it "returns :closed" do
        expect(process.status_indicator_key).to eq(:closed)
      end
    end
  end

  describe "not_started_yet?" do
    context "when is before start and without draft phase" do
      let(:process) do
        create(:legislation_process,
                             start_date:          2.days.from_now,
                             end_date:            10.days.from_now,
                             draft_phase_enabled: false)
      end

      it "returns true" do
        expect(process.not_started_yet?).to be_truthy
      end
    end

    context "when is before start and with draft phase" do
      let(:process) do
        create(:legislation_process,
               start_date:          2.days.from_now,
               end_date:            10.days.from_now,
               draft_phase_enabled: true)
      end

      it "returns true" do
        expect(process.not_started_yet?).to be_truthy
      end
    end

    context "when is in the draft phase" do
      let(:process) { create(:legislation_process, :in_draft_phase) }

      it "returns false" do
        expect(process.not_started_yet?).to be_falsey
      end
    end

    context "when it is active" do
      let(:process) { create(:legislation_process, :open) }

      it "returns false" do
        expect(process.not_started_yet?).to be_falsey
      end
    end

    context "when it is closed" do
      let(:process) { create(:legislation_process, :past) }

      it "returns false" do
        expect(process.not_started_yet?).to be_falsey
      end
    end
  end

  describe "in_draft_phase?" do
    context "when is before start and without draft phase" do
      let(:process) do
        create(:legislation_process,
                             start_date:          2.days.from_now,
                             end_date:            10.days.from_now,
                             draft_phase_enabled: false)
      end

      it "returns false" do
        expect(process.in_draft_phase?).to be_falsey
      end
    end

    context "when is before start and with draft phase" do
      let(:process) do
        create(:legislation_process,
               start_date:          4.days.from_now,
               end_date:            10.days.from_now,
               draft_start_date:    1.day.from_now,
               draft_end_date:      2.days.from_now,
               draft_phase_enabled: true)
      end

      it "returns false" do
        expect(process.in_draft_phase?).to be_falsey
      end
    end

    context "when is in the draft phase" do
      let(:process) { create(:legislation_process, :in_draft_phase) }

      it "returns true" do
        expect(process.in_draft_phase?).to be_truthy
      end
    end

    context "when it is active" do
      let(:process) { create(:legislation_process, :open) }

      it "returns false" do
        expect(process.in_draft_phase?).to be_falsey
      end
    end

    context "when it is closed" do
      let(:process) { create(:legislation_process, :past) }

      it "returns false" do
        expect(process.in_draft_phase?).to be_falsey
      end
    end
  end

  context ".total_comments" do
    let(:process) { create(:legislation_process) }

    before do
      create(:comment, commentable: create(:legislation_question, process: process))
      create(:comment, commentable: create(:legislation_proposal, process: process))
      create(:comment, commentable: create(:legislation_annotation,
                                           draft_version: create(:legislation_draft_version, process: process)))
      create(:legislation_question_comment)
      create(:proposal_comment)
      create(:legislation_annotation_comment)
    end

    it "returns sum of the comments for questions, proposals, and annotations of the specific process" do
      expect(process.total_comments).to eq 4
    end

    it "returns 0 if there are no comments yet" do
      expect(create(:legislation_process).total_comments).to be_zero
    end
  end

  context ".comments" do
    let(:process) { create(:legislation_process) }
    let(:question_comment) { create(:comment, commentable: create(:legislation_question, process: process)) }
    let(:proposal_comment) { create(:comment, commentable: create(:legislation_proposal, process: process)) }
    let(:annotation) do
      create(:legislation_annotation,
                              draft_version: create(:legislation_draft_version, process: process)) end
    let(:initial_annotation_comment) { annotation.comments.first }
    let(:annotation_comment) { create(:comment, commentable: annotation) }

    before do
      question_comment
      proposal_comment
      annotation_comment
      create(:legislation_question_comment)
      create(:proposal_comment)
      create(:legislation_annotation_comment)
    end

    it "returns all comments of the specific process" do
      expect(process.comments.size).to eq 4
    end

    it "returns correct comment types" do
      expected_types = ["Legislation::Annotation", "Legislation::Proposal", "Legislation::Question"]
      expect(process.comments.pluck(:commentable_type).uniq.sort).to eq(expected_types)
    end

    it "returns question comments" do
      expect(process.comments.include?(question_comment)).to be_truthy
    end

    it "returns proposal comments" do
      expect(process.comments.include?(proposal_comment)).to be_truthy
    end

    it "returns annotation comments" do
      expect(process.comments.include?(initial_annotation_comment)).to be_truthy
      expect(process.comments.include?(annotation_comment)).to be_truthy
    end
  end

  context ".comments_sql_for_csv" do
    let(:expected_sql) do
      "SELECT DISTINCT \"comments\".\"id\", comment_translations.body, \"users\".\"username\", "\
      "REPLACE(commentable_type, 'Legislation::', '') AS type FROM \"comments\" INNER JOIN \"users\" ON \"users\"."\
      "\"id\" = \"comments\".\"user_id\" INNER JOIN \"comment_translations\" ON \"comment_translations\"."\
      "\"comment_id\" = \"comments\".\"id\" AND \"comment_translations\".\"hidden_at\" IS NULL WHERE ((\"comments\".\""\
      "hidden_at\" IS NULL AND \"comments\".\"commentable_type\" = 'Legislation::Question' AND 1=0 OR \"comments\".\""\
      "hidden_at\" IS NULL AND \"comments\".\"commentable_type\" = 'Legislation::Proposal' AND 1=0) OR \"comments\"."\
      "\"hidden_at\" IS NULL AND \"comments\".\"commentable_type\" = 'Legislation::Annotation' AND 1=0) AND "\
      "\"comment_translations\".\"hidden_at\" IS NULL AND \"comment_translations\".\"locale\" IN ('en', 'de', 'es',"\
      " 'fr', 'nl', 'pt-BR', 'zh-CN')"
    end

    it "returns the correct SQL" do
      expect(process.comments_sql_for_csv).to eq expected_sql
    end
  end
end
