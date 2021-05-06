require "rails_helper"

describe "Admin comments" do
  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Index - list all comments" do
    comment = create(:comment)

    visit admin_root_path
    within("#side_menu") { click_link I18n.t("admin.menu.comments") }
    within("#side_menu") { click_link I18n.t("admin.menu.comments_all") }

    expect(page).to have_content comment.body
  end

  scenario "To export - lists all available processes" do
    process  = create(:legislation_process)
    process2 = create(:legislation_process)
    process3 = create(:legislation_process)

    visit admin_root_path
    within("#side_menu") { click_link I18n.t("admin.menu.comments") }
    within("#side_menu") { click_link I18n.t("admin.menu.comments_to_export") }

    expect(page).to have_content process.title
    expect(page).to have_content process2.title
    expect(page).to have_content process3.title
  end
end
