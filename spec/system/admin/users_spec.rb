require "rails_helper"

describe "Admin users" do
  let(:admin) { create(:administrator) }
  let!(:user) { create(:user, display_name: "Jose Luis Balbin") }

  before do
    login_as(admin.user)
    visit admin_users_path
  end

  scenario "Index" do
    expect(page).to have_link user.name
    expect(page).to have_content user.email
    expect(page).to have_content admin.name
    expect(page).to have_content admin.email
  end

  scenario "The username links to their public profile" do
    click_link user.name

    expect(page).to have_current_path(user_path(user))
  end

  scenario "Search" do
    fill_in :search, with: "Luis"
    click_button "Search"

    expect(page).to have_content user.name
    expect(page).to have_content user.email
    expect(page).not_to have_content admin.name
    expect(page).not_to have_content admin.email
  end

  scenario "Promotes the user to Admin" do
    fill_in :search, with: "Luis"
    click_button "Search"

    click_link I18n.t("admin.users.actions.promote_admin")
    expect(page).to have_content I18n.t("admin.users.promote_to_admin.success")

    fill_in :search, with: "Luis"
    click_button "Search"
    expect(page).not_to have_content I18n.t("admin.users.actions.promote_admin")
    expect(page).to have_content "admin"
  end

  scenario "Promotes the user to OECD Representative" do
    create(:user, display_name: "John Doe")
    fill_in :search, with: "Doe"
    click_button "Search"

    click_link I18n.t("admin.users.actions.promote_oecd_representative")
    expect(page).to have_content I18n.t("admin.users.promote_to_oecd_representative.success")

    fill_in :search, with: "Doe"
    click_button "Search"
    expect(page).not_to have_content I18n.t("admin.users.actions.promote_oecd_representative")
    expect(page).to have_content "oecd_representative"
  end
end
