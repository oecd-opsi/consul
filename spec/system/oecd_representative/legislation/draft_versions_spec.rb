require "rails_helper"

describe "Oecd Representative legislation draft versions" do
  let(:oecd_representative) { create(:oecd_representative).user }
  before do
    login_as(oecd_representative)
  end

  context "Feature flag" do
    scenario "Disabled with a feature flag" do
      Setting["process.legislation"] = nil
      process = create(:legislation_process, author: oecd_representative)
      expect { visit oecd_representative_legislation_process_draft_versions_path(process) }
        .to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  context "Index" do
    scenario "Displaying legislation process draft versions" do
      process = create(:legislation_process, title: "An example legislation process", author: oecd_representative)
      draft_version = create(:legislation_draft_version, process: process, title: "Version 1")

      visit oecd_representative_legislation_processes_path(filter: "all")

      click_link "An example legislation process"
      click_link "Drafting"
      click_link "Version 1"

      expect(page).to have_content(draft_version.title)
      expect(page).to have_content(draft_version.changelog)
    end
  end

  context "Create" do
    scenario "Valid legislation draft version" do
      create(:legislation_process, title: "An example legislation process", author: oecd_representative)

      visit oecd_representative_root_path

      within("#side_menu") do
        click_link I18n.t("layouts.header.collaborative_legislation")
      end

      click_link "All"

      expect(page).to have_content "An example legislation process"

      click_link "An example legislation process"
      click_link "Drafting"

      click_link "Create version"

      fill_in "Version title", with: "Version 3"
      fill_in "Changes", with: "Version 3 changes"
      fill_in "Text", with: "Version 3 body"

      within("form .end") do
        click_button "Create version"
      end

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Version 3"
    end
  end

  context "Update" do
    scenario "Valid legislation draft version", :js do
      process = create(:legislation_process, title: "An example legislation process", author: oecd_representative)
      create(:legislation_draft_version, title: "Version 1", process: process)

      visit oecd_representative_root_path

      within("#side_menu") do
        click_link I18n.t("layouts.header.collaborative_legislation")
      end

      click_link "All"

      expect(page).not_to have_link "All"

      click_link "An example legislation process"
      click_link "Drafting"

      click_link "Version 1"

      fill_in "Version title", with: "Version 1b"

      click_link "Launch text editor"

      fill_in "Text", with: "# Version 1 body\r\n\r\nParagraph\r\n\r\n>Quote"

      within(".fullscreen") do
        click_link "Close text editor"
      end

      click_button "Save changes"

      expect(page).to have_content "Version 1b"
    end
  end
end
