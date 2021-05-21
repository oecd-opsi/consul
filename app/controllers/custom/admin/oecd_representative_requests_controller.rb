class Admin::OecdRepresentativeRequestsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @oecd_representative_requests = @oecd_representative_requests.page(params[:page])
  end

  def show
  end

  def accept
    @oecd_representative_request.accept!

    redirect_to admin_oecd_representative_request_path(@oecd_representative_request),
                notice: I18n.t("admin.oecd_representative_requests.actions.accepted")
  end

  def reject
    @oecd_representative_request.reject!

    redirect_to admin_oecd_representative_request_path(@oecd_representative_request),
                notice: I18n.t("admin.oecd_representative_requests.actions.rejected")
  end
end
