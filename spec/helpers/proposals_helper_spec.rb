require "rails_helper"

describe ProposalsHelper do
  describe "#progress_bar_percentage" do
    it "is 0 if no votes" do
      proposal = create(:proposal)
      expect(progress_bar_percentage(proposal)).to eq 0
    end

    it "is between 1 and 100 if there are votes but less than needed" do
      proposal = create(:proposal, cached_votes_up: Proposal.votes_needed_for_success / 2)
      expect(progress_bar_percentage(proposal)).to eq 50
    end

    it "is 100 if there are more votes than needed" do
      proposal = create(:proposal, cached_votes_up: Proposal.votes_needed_for_success * 2)
      expect(progress_bar_percentage(proposal)).to eq 100
    end
  end

  describe "#supports_percentage" do
    it "is 0 if no votes" do
      proposal = create(:proposal)
      expect(supports_percentage(proposal)).to eq "0%"
    end

    it "is between 0.1 from 1 to 0.1% of needed votes" do
      proposal = create(:proposal, cached_votes_up: 1)
      expect(supports_percentage(proposal)).to eq "0.1%"
    end

    it "is between 1 and 100 if there are votes but less than needed" do
      proposal = create(:proposal, cached_votes_up: Proposal.votes_needed_for_success / 2)
      expect(supports_percentage(proposal)).to eq "50%"
    end

    it "is 100 if there are more votes than needed" do
      proposal = create(:proposal, cached_votes_up: Proposal.votes_needed_for_success * 2)
      expect(supports_percentage(proposal)).to eq "100%"
    end
  end

  describe "toggle_proposal_path" do
    context "when Admin Panel" do
      it "returns correct path for proposal" do
        proposal = create(:proposal)
        expect(helper.toggle_proposal_path(proposal, :admin)).to eq(toggle_selection_admin_proposal_path(proposal))
      end

      it "returns correct path for legislation proposal" do
        proposal = create(:legislation_proposal)
        expect(helper.toggle_proposal_path(proposal, :admin))
          .to eq(toggle_selection_admin_legislation_process_proposal_path(proposal.process, proposal))
      end
    end

    context "when OECD Representative Panel" do
      it "returns correct path for legislation proposal" do
        proposal = create(:legislation_proposal)
        expect(helper.toggle_proposal_path(proposal, :oecd_representative))
          .to eq(toggle_selection_oecd_representative_legislation_process_proposal_path(proposal.process, proposal))
      end
    end
  end
end
