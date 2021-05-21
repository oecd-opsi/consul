require "rails_helper"

describe "Moderate legislation proposals" do
  let(:citizen) { create(:user) }
  let(:user) { create(:oecd_representative).user }

  context "when own legislation process" do
    let(:legislation_process) { create(:legislation_process, author: user, title: "Title1") }
    let(:legislation_proposal) { create(:legislation_proposal, legislation_process_id: legislation_process.id) }

    scenario "Hide", :js do
      login_as(user)
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

  context "when other user legislation process" do
    let(:legislation_process) { create(:legislation_process, title: "Title1") }
    let(:legislation_proposal) { create(:legislation_proposal, legislation_process_id: legislation_process.id) }

    scenario "Hide", :js do
      login_as(user)
      visit legislation_process_proposal_path(legislation_process, legislation_proposal)

      expect(page).not_to have_link("Hide")

      logout
      login_as(citizen)
      visit legislation_process_proposals_path(legislation_process)

      expect(page).not_to have_link("Hide")
    end
  end
end
