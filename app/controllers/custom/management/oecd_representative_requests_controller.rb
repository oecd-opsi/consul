class Management::OecdRepresentativeRequestsController < Management::BaseController
  before_action :authenticate_user!
  before_action :auto_sign_in_manager

  load_and_authorize_resource

  def index
    @oecd_representative_requests = @oecd_representative_requests.page(params[:page])
  end

  def show
  end

  def accept
    @oecd_representative_request.accept!

    redirect_to management_oecd_representative_request_path(@oecd_representative_request),
                notice: I18n.t("management.oecd_representative_requests.actions.accepted")
  end

  def reject
    @oecd_representative_request.reject!

    redirect_to management_oecd_representative_request_path(@oecd_representative_request),
                notice: I18n.t("management.oecd_representative_requests.actions.rejected")
  end

  private

  # disable default current user and ability settings of Management Controllers and use CanCanCan instead
    def verify_manager
      true
    end

    # allow accessing OECD Requests without visiting manager sign in path
    def auto_sign_in_manager
      return true if session[:manager]

      session[:return_to] = request.path
      redirect_to management_sign_in_path
    end

    def current_user
      manager_logged_in
    end
end
