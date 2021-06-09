require "rails_helper"

describe "Notifications" do
  let(:notifiable) { create(:oecd_representative_request) }

  before do
    create(:notification, user: user, notifiable: notifiable)
    login_as(user)
    visit root_path
  end

  context "when logged in as an Admin" do
    let(:user) { create(:administrator).user }

    scenario "View OECD Representative Request notification redirects to Admin view" do
      click_notifications_icon

      first(".notification a").click
      expect(page).to have_current_path(admin_oecd_representative_request_path(notifiable))

      visit notifications_path
      expect(page).to have_css ".notification", count: 0

      visit read_notifications_path
      expect(page).to have_css ".notification", count: 1
    end
  end

  context "when logged in as a Manager" do
    let(:user) { create(:manager).user }

    scenario "View OECD Representative Request notification redirects to Manager view" do
      click_notifications_icon

      first(".notification a").click
      expect(page).to have_current_path(management_oecd_representative_request_path(notifiable))

      visit notifications_path
      expect(page).to have_css ".notification", count: 0

      visit read_notifications_path
      expect(page).to have_css ".notification", count: 1
    end
  end

  context "when logged in as a Standard user" do
    let(:user) { create(:user) }

    scenario "View OECD Representative Request notification redirects to Notifications page" do
      click_notifications_icon

      first(".notification a").click
      expect(page).to have_current_path(notifications_path)

      visit notifications_path
      expect(page).to have_css ".notification", count: 0

      visit read_notifications_path
      expect(page).to have_css ".notification", count: 1
    end
  end
end
