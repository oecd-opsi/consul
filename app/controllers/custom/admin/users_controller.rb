class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @users = User.by_username_email_or_document_number(params[:search]) if params[:search]
    @users = @users.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def promote_to_admin
    @user.create_administrator

    redirect_to admin_users_path, notice: t("admin.users.promote.success")
  end
end
