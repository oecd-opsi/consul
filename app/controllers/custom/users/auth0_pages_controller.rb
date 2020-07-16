class Custom::Users::Auth0PagesController < ApplicationController
  skip_authorization_check

  def confirm_login; end
end
