require "rails_helper"
shared_examples "Users moderation" do
  scenario "Hide" do
    citizen = create(:user)

    debate1 = create(:debate, author: citizen)
    debate2 = create(:debate, author: citizen)
    debate3 = create(:debate)
    comment3 = create(:comment, user: citizen, commentable: debate3, body: "SPAMMER")

    login_as(moderator.user)
    visit debates_path

    expect(page).to have_content(debate1.title)
    expect(page).to have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).to have_content(comment3.body)

    visit debate_path(debate1)

    within("#debate_#{debate1.id}") do
      click_link "Hide author"
    end

    expect(page).to have_current_path(debates_path)
    expect(page).not_to have_content(debate1.title)
    expect(page).not_to have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).not_to have_content(comment3.body)

    logout

    visit root_path

    first(:link, I18n.t("devise_views.menu.login_items.login")).click
    fill_in "user_login",    with: citizen.email
    fill_in "user_password", with: citizen.password
    click_button "Enter"

    expect(page).to have_content "Invalid Email or username or password"
    expect(page).to have_current_path(new_user_session_path)
  end

  scenario "Search and ban users" do
    citizen = create(:user, display_name: "Wanda Maximoff")

    login_as(moderator.user)

    visit moderation_users_path

    expect(page).not_to have_content citizen.name
    fill_in "name_or_email", with: "Wanda"
    click_button "Search"

    within("#moderation_users") do
      expect(page).to have_content citizen.name
      expect(page).not_to have_content "Blocked"
      click_link "Block"
    end

    within("#moderation_users") do
      expect(page).to have_content citizen.name
      expect(page).to have_content "Blocked"
    end
  end
end

describe "Moderate users" do
  context "when logged in as a moderator" do
    let(:moderator) { create(:moderator) }
    it_behaves_like "Users moderation"
  end

  context "when logged in as a admin" do
    let(:moderator) { create(:administrator) }
    it_behaves_like "Users moderation"
  end

  context "when logged in as a manager" do
    let(:moderator) { create(:manager) }
    it_behaves_like "Users moderation"
  end
end
