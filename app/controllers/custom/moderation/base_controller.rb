class Moderation::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :verify_moderator

  skip_authorization_check

  private

    def verify_moderator
      return true if current_user&.moderator? || current_user&.administrator? || current_user&.manager?

      raise CanCan::AccessDenied
    end
end
