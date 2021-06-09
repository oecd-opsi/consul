class OecdRepresentativeRequestsController < ApplicationController
  load_and_authorize_resource
  before_action :redirect_if_already_sent

  def new
    @oecd_representative_request = OecdRepresentativeRequest.new(user: current_user)
  end

  def create
    @oecd_representative_request = current_user.oecd_representative_requests.new(oecd_representative_request_params)
    if @oecd_representative_request.save
      send_notifications
      redirect_to account_path, notice: I18n.t("users.oecd_represetative_requests.flash.create")
    else
      render :new
    end
  end

  private

    def oecd_representative_request_params
      params.require(:oecd_representative_request).permit(:message)
    end

    def redirect_if_already_sent
      return true if current_user.oecd_representative_requests.with_status(:pending).empty?

      redirect_to account_path, alert: I18n.t("users.oecd_represetative_requests.flash.already_sent")
    end

    def send_notifications
      Administrator.all.each do |administrator|
        RequestNotifier.notify!(administrator.user, @oecd_representative_request)
      end

      Manager.all.each do |manager|
        RequestNotifier.notify!(manager.user, @oecd_representative_request)
      end
    end
end
