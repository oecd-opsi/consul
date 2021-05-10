require "rails_helper"

describe OecdRepresentativeRequest do
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
end
