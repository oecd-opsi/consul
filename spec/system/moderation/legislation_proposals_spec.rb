require "rails_helper"
shared_examples "Legislation proposals moderation" do
  scenario "Hide", :js do
    citizen               = create(:user)
    legislation_process   = create(:legislation_process)
    legislation_proposal  = create(:legislation_proposal, legislation_process_id: legislation_process.id)

    login_as(moderator.user)
    visit legislation_process_proposal_path(legislation_process, legislation_proposal)

    within("#legislation_proposal_#{legislation_proposal.id}") do
      accept_confirm { click_link "Hide" }
    end

    expect(page).to have_css("#legislation_proposal_#{legislation_proposal.id}.faded")

    logout
    login_as(citizen)
    visit legislation_process_proposals_path(legislation_process)

    expect(page).to have_css(".proposal-content", count: 0)
    expect(page).not_to have_link("Hide")
  end
end

describe "Moderate legislation proposals" do
  context "when logged in as a moderator" do
    let(:moderator) { create(:moderator) }
    it_behaves_like "Legislation proposals moderation"
  end

  context "when logged in as a admin" do
    let(:moderator) { create(:administrator) }
    it_behaves_like "Legislation proposals moderation"
  end

  context "when logged in as a manager" do
    let(:moderator) { create(:manager) }
    it_behaves_like "Legislation proposals moderation"
  end
end
