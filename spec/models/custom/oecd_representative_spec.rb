require "rails_helper"

describe OecdRepresentative do
  describe "factories" do
    it "creates valid default factory" do
      expect(build(:oecd_representative)).to be_valid
    end
  end

  describe "#validations" do
    it "is not valid without user" do
      oecd_representative = build(:oecd_representative, user: nil)
      expect(oecd_representative).not_to be_valid
    end
  end
end
