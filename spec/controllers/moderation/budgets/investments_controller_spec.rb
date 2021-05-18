require "rails_helper"

describe Moderation::Budgets::InvestmentsController do
  context "when signed in as a moderator" do
    before { sign_in create(:moderator).user }

    describe "PUT moderate" do
      it "keeps query parameters while using protected redirects" do
        id = create(:budget_investment).id

        get :moderate, params: { resource_ids: [id], filter: "all", host: "evil.dev" }

        expect(response).to redirect_to "/moderation/budget_investments?filter=all&resource_ids%5B%5D=#{id}"
      end
    end
  end

  context "when signed in as a manager" do
    before { sign_in create(:manager).user }

    describe "PUT moderate" do
      it "keeps query parameters while using protected redirects" do
        id = create(:budget_investment).id

        get :moderate, params: { resource_ids: [id], filter: "all", host: "evil.dev" }

        expect(response).to redirect_to "/moderation/budget_investments?filter=all&resource_ids%5B%5D=#{id}"
      end
    end
  end

  context "when signed in as a admin" do
    before { sign_in create(:administrator).user }

    describe "PUT moderate" do
      it "keeps query parameters while using protected redirects" do
        id = create(:budget_investment).id

        get :moderate, params: { resource_ids: [id], filter: "all", host: "evil.dev" }

        expect(response).to redirect_to "/moderation/budget_investments?filter=all&resource_ids%5B%5D=#{id}"
      end
    end
  end
end
