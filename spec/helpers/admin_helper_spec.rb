require "rails_helper"

describe AdminHelper do
  describe "#admin_submit_action" do
    it "returns new when the the resource has not been persisted" do
      poll = build(:poll)
      expect(admin_submit_action(poll)).to eq("new")
    end

    it "returns edit when the the resource has been persisted" do
      poll = create(:poll)
      expect(admin_submit_action(poll)).to eq("edit")
    end

    describe "#user_roles" do
      context "when user is an OECD Representative" do
        it "returns :oecd_representative in roles" do
          user = create(:oecd_representative).user
          expect(helper.user_roles(user)).to eq %i[oecd_representative]
        end
      end
    end

    describe "#menu_profiles?" do
      let(:profiles_controllers) do
        %w[
          administrators organizations officials moderators
          valuators managers users oecd_representatives
        ]
      end

      context "when profiles controller" do
        it "returns true" do
          profiles_controllers.each do |controller|
            allow(helper).to receive(:controller_name).and_return(controller)
            expect(helper.menu_profiles?).to be_truthy
          end
        end
      end

      context "when other controller" do
        it "returns flase" do
          allow(helper).to receive(:controller_name).and_return(:collaborative_legislation)
          expect(helper.menu_profiles?).to be_falsey
        end
      end
    end
  end

  describe "namespace" do
    context "when one of OecdRepresentative controllers" do
      it "returns oecd_representative" do
        allow(controller).to receive(:class).and_return(OecdRepresentative::BaseController)

        expect(helper.send(:namespace)).to eq("oecd_representative")
      end
    end

    context "when controller other than OecdRepresentative " do
      it "returns namespace name" do
        allow(controller).to receive(:class).and_return(Admin::BaseController)

        expect(helper.send(:namespace)).to eq("admin")
      end
    end
  end
end
