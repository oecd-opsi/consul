require "rails_helper"

describe OecdRepresentativeRequest do
  let(:resource) { create(:oecd_representative_request) }
  describe "factories" do
    it "creates valid default factory" do
      expect(build(:oecd_representative_request)).to be_valid
    end
  end

  describe "#validations" do
    it "is not valid without user" do
      oecd_representative_request = build(:oecd_representative_request, user: nil)
      expect(oecd_representative_request).not_to be_valid
    end

    it "is not valid without message" do
      oecd_representative_request = build(:oecd_representative_request, message: nil)
      expect(oecd_representative_request).not_to be_valid
    end
  end

  describe "accept!" do
    before { resource.accept! }

    it "accepts the request" do
      expect(resource.reload.status).to eq :accepted
    end

    it "makes the requester an OECD representative" do
      expect(resource.user).to be_oecd_representative
    end
  end

  describe "reject!" do
    before { resource.reject! }

    it "rejects the request" do
      expect(resource.reload.status).to eq :rejected
    end

    it "does not makes the requester an OECD representative" do
      expect(resource.reload.user).not_to be_oecd_representative
    end
  end
end
