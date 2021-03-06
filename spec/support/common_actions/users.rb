module Users
  def sign_up(email = "manuela@consul.dev", password = "judgementday")
    visit "/"

    first(:link, I18n.t("devise_views.menu.login_items.signup")).click

    fill_in "user_username",              with: "Manuela Carmena #{rand(99999)}"
    fill_in "user_email",                 with: email
    fill_in "user_password",              with: password
    fill_in "user_password_confirmation", with: password
    check "user_terms_of_service"

    click_button I18n.t("devise_views.users.registrations.new.submit")
  end

  def login_through_form_with_email_and_password(email = "manuela@consul.dev", password = "judgementday")
    visit root_path
    first(:link, I18n.t("devise_views.menu.login_items.login")).click

    fill_in "user_login", with: email
    fill_in "user_password", with: password

    click_button "Enter"
  end

  def login_through_form_as(user)
    visit root_path

    first(:link, I18n.t("devise_views.menu.login_items.login")).click

    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password

    click_button "Enter"
  end

  def login_through_form_as_officer(user)
    visit root_path

    first(:link, I18n.t("devise_views.menu.login_items.login")).click

    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password

    click_button "Enter"
    visit new_officing_residence_path
  end

  def login_as_manager(manager = create(:manager))
    login_as(manager.user)
    visit management_sign_in_path
  end

  def sign_in_as_manager(manager = create(:manager))
    sign_in manager.user
    session[:manager] = { "login" => "manager_user_#{manager.user_id}" }
  end

  def login_managed_user(user)
    allow_any_instance_of(Management::BaseController).to receive(:managed_user).and_return(user)
  end

  def confirm_email
    body = ActionMailer::Base.deliveries.last&.body
    expect(body).to be_present

    sent_token = /.*confirmation_token=(.*)".*/.match(body.to_s)[1]
    visit user_confirmation_path(confirmation_token: sent_token)

    expect(page).to have_content "Your account has been confirmed"
  end

  def confirm_newly_created_user
    user = User.last
    user.reload && user.confirm
  end

  def reset_password
    create(:user, email: "manuela@consul.dev")

    visit "/"
    first(:link, I18n.t("devise_views.menu.login_items.login")).click
    click_link "Forgotten your password?"

    fill_in "user_email", with: "manuela@consul.dev"
    click_button "Send instructions"
  end

  def expect_to_be_signed_in
    expect(find("a[href='#{account_path}']")).to be_visible
  end

  def expect_not_to_be_signed_in
    expect { find("a[href='#{account_path}']") }.to raise_error(Capybara::ElementNotFound)
  end

  def sign_out(close_notification: true)
    find("a[href='#{account_path}'][title='#{I18n.t("layouts.header.my_account_link")}']").hover
    click_link I18n.t("devise_views.menu.login_items.logout")

    if close_notification && page.has_css?("button.close-button")
      first("div.callout").find("button.close-button").click
    end
  end
end
