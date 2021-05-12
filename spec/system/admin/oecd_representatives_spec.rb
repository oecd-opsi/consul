require "rails_helper"

describe "Admin OECD representatives" do
  let!(:user) { create(:user) }
  let!(:oecd_representative) { create(:oecd_representative) }

  before do
    login_as(create(:administrator).user)
    visit admin_oecd_representatives_path
  end

  scenario "Index" do
    expect(page).to have_content oecd_representative.name
    expect(page).to have_content oecd_representative.email
    expect(page).not_to have_content user.name
  end

  scenario "Create OECD Representative", :js do
    fill_in "name_or_email", with: user.email
    click_button "Search"

    expect(page).to have_content user.name
    click_link "Add"
    accept_alert "Are you sure?"
    within("#oecd_representatives") do
      expect(page).to have_content user.name
    end
  end

  scenario "Delete OECD Representative" do
    click_link "Delete"

    within("#oecd_representatives") do
      expect(page).not_to have_content oecd_representative.name
    end
  end

  context "Search" do
    let(:user)      { create(:user, username: "Taylor Swift", email: "taylor@swift.com") }
    let(:user2)     { create(:user, username: "Stephanie Corneliussen", email: "steph@mrrobot.com") }
    let!(:oecd_representative1) { create(:oecd_representative, user: user) }
    let!(:oecd_representative2) { create(:oecd_representative, user: user2) }

    before do
      visit admin_oecd_representatives_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(oecd_representative1.name)
      expect(page).to have_content(oecd_representative2.name)

      fill_in "name_or_email", with: " "
      click_button "Search"

      expect(page).to have_content(I18n.t("admin.oecd_representatives.search.title"))
      expect(page).to have_content("No results found")
      expect(page).not_to have_content(oecd_representative1.name)
      expect(page).not_to have_content(oecd_representative2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(oecd_representative1.name)
      expect(page).to have_content(oecd_representative2.name)

      fill_in "name_or_email", with: "Taylor"
      click_button "Search"

      expect(page).to have_content(I18n.t("admin.oecd_representatives.search.title"))
      expect(page).to have_content(oecd_representative1.name)
      expect(page).not_to have_content(oecd_representative.name)
    end

    scenario "search by email" do
      expect(page).to have_content(oecd_representative1.email)
      expect(page).to have_content(oecd_representative2.email)

      fill_in "name_or_email", with: oecd_representative2.email
      click_button "Search"

      expect(page).to have_content(I18n.t("admin.oecd_representatives.search.title"))
      expect(page).to have_content(oecd_representative2.email)
      expect(page).not_to have_content(oecd_representative1.email)
    end

    scenario "Delete after searching" do
      fill_in "Search user by name or email", with: oecd_representative2.email
      click_button "Search"

      click_link "Delete"

      expect(page).to have_content(oecd_representative1.email)
      expect(page).not_to have_content(oecd_representative2.email)
    end
  end
end
