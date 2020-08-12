require "rails_helper"

describe "Sessions", js: true do
  let(:debate) { create(:debate) }

  scenario "Staying in the same page after doing login/logout" do
    user = create(:user, sign_in_count: 10)

    visit debate_path(debate)

    login_through_form_as(user)

    expect(page).to have_content("You have been signed in successfully")
    expect(page).to have_current_path(debate_path(debate))

    find(:button, class: "close-button").click
    sign_out(close_notification: false)

    expect(page).to have_content("You have been signed out successfully")
    expect(page).to have_current_path(debate_path(debate))
  end

  context "with Auth0 login enabled" do
    let(:auth0_hash_with_verified_email) do
      {
        provider: "auth0",
        uid:      "12345",
        info:     {
          name:     "manuela",
          email:    "manuelacarmena@example.com",
          verified: "1"
        }
      }
    end

    let(:confirm_login_redirect_uri) { confirm_login_url(port: Capybara.current_session.server.port) }
    let(:root_redirect_uri) { root_url(port: Capybara.current_session.server.port) }

    before do
      Setting["feature.auth0_login"] = true
      OmniAuth.config.add_mock(:auth0, auth0_hash_with_verified_email)
    end

    after do
      Setting["feature.auth0_login"] = false
    end

    scenario "Redirecting to WP when logout triggered from Consul" do
      visit debate_path(debate)

      visit confirm_login_path

      expect_to_be_signed_in
      expect(page).to have_current_path(debate_path(debate))

      find(:button, class: "close-button").click
      sign_out

      expect(page).to have_current_path(
                        "#{ENV["WORDPRESS_SIGN_OUT_URL"]}?redirect_uri=#{URI::encode(root_redirect_uri)}"
                      )
    end

    scenario "Redirecting to WP when logout triggered not in Consul", js: false do
      Capybara.current_session.driver.header "Referer", ENV["WORDPRESS_SIGN_IN_URL"]

      visit destroy_user_session_path

      expect(page).to have_current_path("#{ENV["WORDPRESS_SIGN_OUT_URL"]}")
    end

    scenario "Redirecting to WP Sign after clicking on Sign in button" do
      visit "/"
      click_link I18n.t("devise_views.menu.login_items.login")
      expected_path = "#{ENV["WORDPRESS_SIGN_IN_URL"]}?redirect_uri="\
                      "#{URI::encode(confirm_login_redirect_uri)}"
      expect(page).to have_current_path(expected_path)
    end
  end
end
