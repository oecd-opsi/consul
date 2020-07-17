require "rails_helper"

describe Custom::Users::Auth0PagesController do
  before do
    Setting["feature.auth0_login"] = true
  end

  after do
    Setting["feature.auth0_login"] = false
  end

  it "renders Confirm login page" do
    get confirm_login_path

    expect(response).to have_http_status(200)
  end
end
