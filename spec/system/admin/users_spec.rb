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

  scenario "Demotes the admin user to OECD Representative" do
    other_user = create(:administrator).user
    fill_in :search, with: other_user.name
    click_button "Search"

    click_link I18n.t("admin.users.actions.demote_to_oecd_representative")
    expect(page).to have_content I18n.t("admin.users.demote_to_oecd_representative.success")

    fill_in :search, with: other_user.name
    click_button "Search"
    expect(page).to have_content I18n.t("admin.users.actions.promote_admin")
    expect(page).to have_content I18n.t("admin.users.actions.demote_to_user")
    expect(page).not_to have_content I18n.t("admin.users.actions.demote_to_oecd_representative")
    expect(page).to have_content "oecd_representative"
    expect(other_user.reload).to be_oecd_representative
  end

  scenario "Demotes the Admin user to Standard user" do
    other_user = create(:administrator).user
    fill_in :search, with: other_user.name
    click_button "Search"

    click_link I18n.t("admin.users.actions.demote_to_user")
    expect(page).to have_content I18n.t("admin.users.demote_to_user.success")

    fill_in :search, with: other_user.name
    click_button "Search"
    expect(page).to have_content I18n.t("admin.users.actions.promote_admin")
    expect(page).to have_content I18n.t("admin.users.actions.promote_oecd_representative")
    expect(page).not_to have_content I18n.t("admin.users.actions.demote_to_user")
    expect(page).not_to have_content I18n.t("admin.users.actions.demote_to_oecd_representative")
    expect(page).to have_content "user"
    expect(other_user.reload).to be_standard_user
  end

  scenario "Demotes the OECD representative to Standard user" do
    other_user = create(:oecd_representative).user
    fill_in :search, with: other_user.name
    click_button "Search"

    click_link I18n.t("admin.users.actions.demote_to_user")
    expect(page).to have_content I18n.t("admin.users.demote_to_user.success")

    fill_in :search, with: other_user.name
    click_button "Search"
    expect(page).to have_content I18n.t("admin.users.actions.promote_admin")
    expect(page).to have_content I18n.t("admin.users.actions.promote_oecd_representative")
    expect(page).not_to have_content I18n.t("admin.users.actions.demote_to_user")
    expect(page).not_to have_content I18n.t("admin.users.actions.demote_to_oecd_representative")
    expect(page).to have_content "user"
    expect(other_user.reload).to be_standard_user
  end
end
