require "rails_helper"

describe "Account" do
  let(:user) { create(:user, username: "Manuela Colau") }
  let(:auth0_client_mock) { double(:auth0_client) }

  before do
    Setting["feature.auth0_login"] = true
    login_as(user)
    create(:identity, user: user, uid: "auth0|test-uid")

    allow(Auth0Client).to receive(:new).and_return(auth0_client_mock)
  end

  after do
    Setting["feature.auth0_login"] = false
  end

  scenario "Show" do
    visit root_path

    first(:link, I18n.t("layouts.header.my_account_link")).click

    expect(page).to have_current_path(account_path, ignore_query: true)

    expect(page).to have_selector("input[value='Manuela Colau']")

    expect(page).to have_selector(avatar("Manuela Colau"))
  end

  scenario "Show organization" do
    create(:organization, user: user, name: "Manuela Corp")

    visit account_path

    expect(page).to have_selector("input[value='Manuela Corp']")
    expect(page).not_to have_selector("input[value='Manuela Colau']")

    expect(page).to have_selector(avatar("Manuela Corp"))
  end

  scenario "Edit" do
    visit account_path

    fill_in "account_username", with: "Larry Bird"
    check "account_email_on_comment"
    check "account_email_on_comment_reply"
    uncheck "account_email_digest"
    uncheck "account_email_on_direct_message"
    click_button "Save changes"

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Larry Bird']")
    expect(find("#account_email_on_comment")).to be_checked
    expect(find("#account_email_on_comment_reply")).to be_checked
    expect(find("#account_email_digest")).not_to be_checked
    expect(find("#account_email_on_direct_message")).not_to be_checked
  end

  scenario "Edit email address" do
    visit account_path

    click_link "Change my credentials"

    fill_in "user_email", with: "new_user_email@example.com"

    allow(auth0_client_mock).to receive(:users).and_return([])
    allow(auth0_client_mock).to receive(:update_user).and_return(true)
    click_button class: "button-update-email"

    notice = "Your account has been updated successfully;"\
             " however, we need to verify your new email address."\
             " Please check your email and click on the link to"\
             " complete the confirmation of your new email address."
    expect(page).to have_content notice

    # we need to confirm the user manually, because right now it is done via Auth0
    user.reload && user.confirm

    visit account_path

    click_link "Change my credentials"
    fill_in "user_password", with: "new_password"
    fill_in "user_password_confirmation", with: "new_password"
    click_button class: "button-update-password"

    notice = "Your account has been updated successfully"
    expect(page).to have_content notice

    logout

    login_as(user)

    visit account_path
    click_link "Change my credentials"
    expect(page).to have_selector("input[value='new_user_email@example.com']")
  end

  scenario "Edit Organization" do
    create(:organization, user: user, name: "Manuela Corp")
    visit account_path

    fill_in "account_organization_attributes_name", with: "Google"
    check "account_email_on_comment"
    check "account_email_on_comment_reply"

    click_button "Save changes"

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Google']")
    expect(find("#account_email_on_comment")).to be_checked
    expect(find("#account_email_on_comment_reply")).to be_checked
  end

  context "Option to display badge for official position" do
    scenario "Users with official position of level 1" do
      official_user = create(:user, official_level: 1)

      login_as(official_user)
      visit account_path

      check "account_official_position_badge"
      click_button "Save changes"
      expect(page).to have_content "Changes saved"

      visit account_path
      expect(find("#account_official_position_badge")).to be_checked
    end

    scenario "Users with official position of level 2 and above" do
      official_user2 = create(:user, official_level: 2)
      official_user3 = create(:user, official_level: 3)

      login_as(official_user2)
      visit account_path

      expect(page).not_to have_css "#account_official_position_badge"

      login_as(official_user3)
      visit account_path

      expect(page).not_to have_css "#account_official_position_badge"
    end
  end

  scenario "Errors on edit" do
    visit account_path

    fill_in "account_username", with: ""
    click_button "Save changes"

    expect(page).to have_content "1 error prevented this Account from being saved."
  end

  scenario "Errors editing credentials" do
    visit root_path

    first(:link, I18n.t("layouts.header.my_account_link")).click

    expect(page).to have_current_path(account_path, ignore_query: true)

    expect(page).to have_link("Change my credentials")
    click_link "Change my credentials"
    fill_in "user_password", with: "short"
    click_button class: "button-update-password"

    expect(page).to have_content "2 errors prevented this Account from being saved."\
  end

  scenario "Erasing account" do
    Setting["feature.auth0_login"] = false
    visit account_path

    click_link I18n.t("account.show.erase_account_link")

    fill_in "user_erase_reason", with: "a test"

    click_button I18n.t("devise_views.users.registrations.delete_form.submit")

    expect(page).to have_content "Goodbye! Your account has been cancelled. We hope to see you again soon."

    login_through_form_as(user)

    expect(page).to have_content "Invalid Email or username or password"
  end

  context "Recommendations" do
    scenario "are enabled by default" do
      visit account_path

      expect(page).to have_content("Recommendations")
      expect(page).to have_content("Show debates recommendations")
      expect(page).to have_content("Show proposals recommendations")
      expect(find("#account_recommended_debates")).to be_checked
      expect(find("#account_recommended_proposals")).to be_checked
    end

    scenario "can be disabled through 'My account' page" do
      visit account_path

      expect(page).to have_content("Recommendations")
      expect(page).to have_content("Show debates recommendations")
      expect(page).to have_content("Show proposals recommendations")
      expect(find("#account_recommended_debates")).to be_checked
      expect(find("#account_recommended_proposals")).to be_checked

      uncheck "account_recommended_debates"
      uncheck "account_recommended_proposals"

      click_button "Save changes"

      expect(find("#account_recommended_debates")).not_to be_checked
      expect(find("#account_recommended_proposals")).not_to be_checked

      user.reload

      expect(user.recommended_debates).to be(false)
      expect(user.recommended_proposals).to be(false)
    end
  end
end
