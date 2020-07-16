class Custom::Users::Auth0PagesController < ApplicationController
  skip_authorization_check

  def confirm_login; end

  # do not store pages from this controller for after sign in/up redirect
  def store_location_for(resource_or_scope, location); end
end
