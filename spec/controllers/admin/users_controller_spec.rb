require "rails_helper"

describe Admin::UsersController do
  before { sign_in create(:administrator).user }

  describe "GET promote_to_admin" do
    context "when user can be promoted to Admin" do
      let(:user) { create(:user) }

      before { get :promote_to_admin, params: { id: user.id } }

      it "promotes the user to Admin" do
        expect(user.reload).to be_administrator
      end

      it "shows flash notice" do
        expect(flash[:notice]).to eq(I18n.t("admin.users.promote_to_admin.success"))
      end

      it "redirects back to users list" do
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when the user cannot be promoted to Admin" do
      let(:user) { create(:administrator).user }

      before { get :promote_to_admin, params: { id: user.id } }

      it "returns Access Denied" do
        expect(response.code).to eq("302")
      end
    end

    context "when the user cannot be found" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :promote_to_admin, params: { id: "not-existing" } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET promote_to_oecd_representative" do
    context "when user can be promoted to OECD Representative" do
      let(:user) { create(:user) }

      before { get :promote_to_oecd_representative, params: { id: user.id } }

      it "promotes the user to Admin" do
        expect(user.reload).to be_oecd_representative
      end

      it "shows flash notice" do
        expect(flash[:notice]).to eq(I18n.t("admin.users.promote_to_oecd_representative.success"))
      end

      it "redirects back to users list" do
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when the user cannot be promoted to OECD Representative" do
      let(:user) { create(:oecd_representative).user }

      before { get :promote_to_oecd_representative, params: { id: user.id } }

      it "returns Access Denied" do
        expect(response.code).to eq("302")
      end
    end

    context "when the user cannot be found" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :promote_to_oecd_representative, params: { id: "not-existing" } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET demote_to_oecd_representative" do
    context "when user can be demoted to OECD Representative" do
      let(:user) { create(:administrator).user }

      before { get :demote_to_oecd_representative, params: { id: user.id } }

      it "demotes the user to OECD representative" do
        expect(user.reload).to be_oecd_representative
        expect(user.reload).not_to be_administrator
      end

      it "shows flash notice" do
        expect(flash[:notice]).to eq(I18n.t("admin.users.demote_to_oecd_representative.success"))
      end

      it "redirects back to users list" do
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when the user cannot be demoted to OECD Representative" do
      let(:user) { create(:oecd_representative).user }

      before { get :demote_to_oecd_representative, params: { id: user.id } }

      it "returns Access Denied" do
        expect(response.code).to eq("302")
      end
    end

    context "when the user cannot be found" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :demote_to_oecd_representative, params: { id: "not-existing" } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET demote_to_user" do
    context "when user can be demoted to User" do
      let(:user) { create(:administrator).user }

      before { get :demote_to_user, params: { id: user.id } }

      it "demotes the user to Standard user" do
        expect(user.reload).to be_standard_user
        expect(user.reload).not_to be_administrator
      end

      it "shows flash notice" do
        expect(flash[:notice]).to eq(I18n.t("admin.users.demote_to_user.success"))
      end

      it "redirects back to users list" do
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when the user cannot be demoted to User" do
      let(:user) { create(:manager).user }

      before { get :demote_to_user, params: { id: user.id } }

      it "returns Access Denied" do
        expect(response.code).to eq("302")
      end
    end

    context "when the user cannot be found" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { get :demote_to_user, params: { id: "not-existing" } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
