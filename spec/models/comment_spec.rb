require "rails_helper"

describe Comment do
  let(:comment) { build(:comment) }

  it_behaves_like "has_public_author"
  it_behaves_like "globalizable", :comment
  it_behaves_like "acts as paranoid", :comment

  it "is valid" do
    expect(comment).to be_valid
  end

  it "updates cache_counter in debate after hide and restore" do
    debate  = create(:debate)
    comment = create(:comment, commentable: debate)

    expect(debate.reload.comments_count).to eq(1)
    comment.hide
    expect(debate.reload.comments_count).to eq(0)
    comment.restore
    expect(debate.reload.comments_count).to eq(1)
  end

  describe "#as_administrator?" do
    it "is true if comment has administrator_id, false otherway" do
      expect(comment).not_to be_as_administrator

      comment.administrator_id = 33

      expect(comment).to be_as_administrator
    end
  end

  describe "#as_moderator?" do
    it "is true if comment has moderator_id, false otherway" do
      expect(comment).not_to be_as_moderator

      comment.moderator_id = 21

      expect(comment).to be_as_moderator
    end
  end

  describe "#confidence_score" do
    it "takes into account percentage of total votes and total_positive and total negative votes" do
      comment = create(:comment, :with_confidence_score, cached_votes_up: 100, cached_votes_total: 100)
      expect(comment.confidence_score).to eq(10000)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 0, cached_votes_total: 100)
      expect(comment.confidence_score).to eq(0)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 75, cached_votes_total: 100)
      expect(comment.confidence_score).to eq(3750)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 750, cached_votes_total: 1000)
      expect(comment.confidence_score).to eq(37500)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 10, cached_votes_total: 100)
      expect(comment.confidence_score).to eq(-800)

      comment = create(:comment, :with_confidence_score, cached_votes_up: 0, cached_votes_total: 0)
      expect(comment.confidence_score).to eq(1)
    end

    describe "actions which affect it" do
      let(:comment) { create(:comment, :with_confidence_score) }

      it "increases with like" do
        previous = comment.confidence_score
        5.times { comment.vote_by(voter: create(:user), vote: true) }
        expect(previous).to be < comment.confidence_score
      end

      it "decreases with dislikes" do
        comment.vote_by(voter: create(:user), vote: true)
        previous = comment.confidence_score
        3.times { comment.vote_by(voter: create(:user), vote: false) }
        expect(previous).to be > comment.confidence_score
      end
    end
  end

  describe "cache" do
    let(:comment) { create(:comment) }

    it "expires cache when it has a new vote" do
      expect { create(:vote, votable: comment) }
        .to change { comment.updated_at }
    end

    it "expires cache when hidden" do
      expect { comment.hide }
        .to change { comment.updated_at }
    end

    it "expires cache when the author is hidden" do
      expect { comment.user.hide }
        .to change { [comment.reload.updated_at, comment.author.updated_at] }
    end

    it "expires cache when the author is erased" do
      expect { comment.user.erase }
        .to change { [comment.reload.updated_at, comment.author.updated_at] }
    end

    it "expires cache when the author changes" do
      expect { comment.user.update(username: "Isabel") }
        .to change { [comment.reload.updated_at, comment.author.updated_at] }
    end

    it "expires cache when the author's organization get verified" do
      create(:organization, user: comment.user)
      expect { comment.user.organization.verify }
        .to change { [comment.reload.updated_at, comment.author.updated_at] }
    end
  end

  describe "#author_id?" do
    it "returns the user's id" do
      expect(comment.author_id).to eq(comment.user.id)
    end
  end

  describe "not_as_admin_or_moderator" do
    it "returns only comments posted as regular user" do
      comment1 = create(:comment)
      create(:comment, administrator_id: create(:administrator).id)
      create(:comment, moderator_id: create(:moderator).id)

      expect(Comment.not_as_admin_or_moderator).to eq [comment1]
    end
  end

  describe "public_for_api scope" do
    it "returns comments" do
      comment = create(:comment)

      expect(Comment.public_for_api).to eq [comment]
    end

    it "does not return hidden comments" do
      create(:comment, :hidden)

      expect(Comment.public_for_api).to be_empty
    end

    it "returns comments on debates" do
      comment = create(:comment, commentable: create(:debate))

      expect(Comment.public_for_api).to eq [comment]
    end

    it "does not return comments on hidden debates" do
      create(:comment, commentable: create(:debate, :hidden))

      expect(Comment.public_for_api).to be_empty
    end

    it "returns comments on proposals" do
      proposal = create(:proposal)
      comment  = create(:comment, commentable: proposal)

      expect(Comment.public_for_api).to eq [comment]
    end

    it "does not return comments on hidden proposals" do
      create(:comment, commentable: create(:proposal, :hidden))

      expect(Comment.public_for_api).to be_empty
    end

    it "does not return comments on elements which are not debates or proposals" do
      create(:comment, commentable: create(:budget_investment))

      expect(Comment.public_for_api).to be_empty
    end

    it "does not return comments with no commentable" do
      build(:comment, commentable: nil).save!(validate: false)

      expect(Comment.public_for_api).to be_empty
    end

    it "does not return internal valuation comments" do
      create(:comment, :valuation)

      expect(Comment.public_for_api).to be_empty
    end
  end

  describe "#csv_headers" do
    it "retuns CSV_HEADERS as a CSV line" do
      expect(Comment.csv_headers).to eq(CSV.generate_line(described_class::CSV_HEADERS))
    end
  end

  describe ".for_csv" do
    let(:expected_values) do
      CSV.generate_line(
        [
          comment.id,
          comment.commentable_process_title,
          comment.url_to_process,
          comment.user_name,
          comment.formatted_commentable_type,
          comment.url_to_full_draft,
          comment.body,
          comment.url_to_comment,
          comment.original_comment,
          comment.formatted_created_at,
          comment.total_votes,
          comment.total_likes,
          comment.total_dislikes,
          comment.votes_net,
          comment.highlighted_text
        ]
      )
    end
    context "when annotation comment" do
      let(:comment) { create(:legislation_annotation_comment) }

      it "returns complete list of values formatted for CSV" do
        expect(comment.for_csv).to eq(expected_values)
      end
    end

    context "when proposal comment" do
      let(:comment) { create(:comment, commentable: create(:legislation_proposal)) }

      it "returns complete list of values formatted for CSV" do
        expect(comment.for_csv).to eq(expected_values)
      end
    end

    context "when question comment" do
      let(:comment) { create(:legislation_question_comment) }

      it "returns complete list of values formatted for CSV" do
        expect(comment.for_csv).to eq(expected_values)
      end
    end
  end

  describe ".formatted_commentable_type" do
    context "when annotation comment" do
      let(:comment) { create(:legislation_annotation_comment) }

      it "returns complete list of values formatted for CSV" do
        expect(comment.formatted_commentable_type).to eq("Annotation")
      end
    end

    context "when proposal comment" do
      let(:comment) { create(:comment, commentable: create(:legislation_proposal)) }

      it "returns complete list of values formatted for CSV" do
        expect(comment.formatted_commentable_type).to eq("Proposal")
      end
    end

    context "when question comment" do
      let(:comment) { create(:legislation_question_comment) }

      it "returns complete list of values formatted for CSV" do
        expect(comment.formatted_commentable_type).to eq("Question")
      end
    end
  end

  describe ".formatted_created_at" do
    let(:comment) { create(:comment) }

    it "returns the formatted comment creation date" do
      expect(comment.formatted_created_at).to eq(comment.created_at.to_formatted_s(:short))
    end
  end

  describe ".url_to_comment" do
    let(:comment) { create(:comment) }

    it "returns the url to comment" do
      expect(comment.url_to_comment).to eq("http://#{ENV["SERVER_NAME"]}/comments/#{comment.id}")
    end
  end

  describe ".url_to_process" do
    let(:expected_url) { "http://#{ENV["SERVER_NAME"]}/engagement/processes/#{comment.commentable_process.id}" }

    context "when annotation comment" do
      let(:comment) { create(:legislation_annotation_comment) }

      it "returns direct URL to the Process" do
        expect(comment.url_to_process).to eq(expected_url)
      end
    end

    context "when proposal comment" do
      let(:comment) { create(:comment, commentable: create(:legislation_proposal)) }

      it "returns direct URL to the Process" do
        expect(comment.url_to_process).to eq(expected_url)
      end
    end

    context "when question comment" do
      let(:comment) { create(:legislation_question_comment) }

      it "returns direct URL to the Process" do
        expect(comment.url_to_process).to eq(expected_url)
      end
    end
  end

  describe ".url_to_full_draft" do
    context "when annotation comment" do
      let(:expected_url) do
        "http://#{ENV["SERVER_NAME"]}/engagement/processes/#{comment.commentable_process.id}"\
        "/draft_versions/#{comment.commentable.legislation_draft_version_id}"
      end

      let(:comment) { create(:legislation_annotation_comment) }

      it "returns direct URL to the Process" do
        expect(comment.url_to_full_draft).to eq(expected_url)
      end
    end

    context "when proposal comment" do
      let(:comment) { create(:comment, commentable: create(:legislation_proposal)) }

      it "returns nil" do
        expect(comment.url_to_full_draft).to be_nil
      end
    end

    context "when question comment" do
      let(:comment) { create(:legislation_question_comment) }

      it "returns nil" do
        expect(comment.url_to_full_draft).to be_nil
      end
    end
  end

  describe ".original_comment" do
    context "when the comment is not a reply" do
      let(:comment) { create(:legislation_annotation_comment) }

      it "returns nil" do
        expect(comment.original_comment).to be_nil
      end
    end

    context "when comment is a reply" do
      let(:original_comment) { create(:comment, commentable: create(:legislation_proposal)) }
      let(:comment) { create(:comment, commentable: original_comment.commentable, parent: original_comment) }

      it "returns body of orginal comment" do
        expect(comment.original_comment).to eq(original_comment.body)
      end
    end
  end

  describe ".highlighted_text" do
    context "when the comment is not an annotation" do
      let(:comment) { create(:legislation_question_comment) }

      it "returns nil" do
        expect(comment.highlighted_text).to be_nil
      end
    end

    context "when the comment is an annotation" do
      let(:comment) { create(:legislation_annotation_comment) }

      it "returns nil" do
        expect(comment.highlighted_text).to eq(comment.commentable.quote)
      end
    end
  end

  describe ".commentable_annotation?" do
    context "when the comment is not an annotation" do
      let(:comment) { create(:legislation_question_comment) }

      it "returns false" do
        expect(comment.commentable_annotation?).to be_falsey
      end
    end

    context "when the comment is an annotation" do
      let(:comment) { create(:legislation_annotation_comment) }

      it "returns true" do
        expect(comment.commentable_annotation?).to be_truthy
      end
    end
  end

  describe ".votes_net" do
    context "when there are no votes" do
      let(:comment) { create(:legislation_question_comment, cached_votes_up: 0, cached_votes_down: 0) }

      it "returns 0" do
        expect(comment.votes_net).to be_zero
      end
    end

    context "when the comment has some votes" do
      let(:comment) { create(:legislation_annotation_comment, cached_votes_up: 6, cached_votes_down: 2) }

      it "returns total_likes - total_dislikes" do
        expect(comment.votes_net).to eq(4)
      end
    end
  end

  it_behaves_like "urlable"
end
