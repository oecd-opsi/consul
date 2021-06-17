require "rails_helper"

describe TranslatableFormHelper do
  describe "#backend_translations_enabled" do
    before do
      allow(controller).to receive(:class).and_return(controller_mock)
    end

    context "when Admin Panel" do
      let(:controller_mock) { Admin::BannersController }

      it "returns true" do
        expect(helper.backend_translations_enabled?).to be_truthy
      end
    end

    context "when Management Panel" do
      let(:controller_mock) { Management::DashboardController }

      it "returns true" do
        expect(helper.backend_translations_enabled?).to be_truthy
      end
    end

    context "when Valuation Panel" do
      let(:controller_mock) { Valuation::BudgetInvestmentsController }

      it "returns true" do
        expect(helper.backend_translations_enabled?).to be_truthy
      end
    end

    context "when OECD Representative Panel" do
      let(:controller_mock) { OecdRepresentative::Legislation::MilestonesController }

      it "returns true" do
        expect(helper.backend_translations_enabled?).to be_truthy
      end
    end

    context "when controller with disabled translations" do
      let(:controller_mock) { Moderation::DashboardController }

      it "returns false" do
        expect(helper.backend_translations_enabled?).to be_falsey
      end
    end
  end
end
