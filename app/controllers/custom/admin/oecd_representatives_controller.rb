class Admin::OecdRepresentativesController < Admin::BaseController
  load_and_authorize_resource

  def index
    @oecd_representatives = @oecd_representatives.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:oecd_representative)
                 .page(params[:page])
                 .for_render
  end

  def create
    authorize!(:promote_to_oecd_representative, User.find(params[:user_id]))

    @oecd_representative.user_id = params[:user_id]
    @oecd_representative.save!

    redirect_to admin_oecd_representatives_path
  end

  def destroy
    @oecd_representative.destroy!

    redirect_to admin_oecd_representatives_path
  end
end
