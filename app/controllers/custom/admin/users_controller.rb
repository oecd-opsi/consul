class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @users = User.by_display_name_email_or_document_number(params[:search]) if params[:search]
    @users = @users.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def promote_to_admin
    @user.promote_to_admin!

    redirect_to admin_users_path, notice: t("admin.users.promote_to_admin.success")
  end

  def promote_to_oecd_representative
    @user.create_oecd_representative

    redirect_to admin_users_path, notice: t("admin.users.promote_to_oecd_representative.success")
  end

  def demote_to_user
    @user.demote_to_user!

    redirect_to admin_users_path, notice: t("admin.users.demote_to_user.success")
  end

  def demote_to_oecd_representative
    @user.demote_to_oecd_representative!

    redirect_to admin_users_path, notice: t("admin.users.demote_to_oecd_representative.success")
  end
end
