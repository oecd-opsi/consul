class OecdRepresentative::BaseController < ApplicationController
  layout "oecd_representative"
  before_action :authenticate_user!
  before_action :verify_oecd_representative
  #todo: remove
  skip_authorization_check

  private

    def verify_oecd_representative
      raise CanCan::AccessDenied unless current_user&.oecd_representative?
    end
end
