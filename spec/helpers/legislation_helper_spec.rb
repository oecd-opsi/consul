require "rails_helper"

describe LegislationHelper do
  let(:process) { build(:legislation_process) }

  it "is valid" do
    expect(process).to be_valid
  end

  describe "banner colors presence" do
    it "background and font color exist" do
      @process = build(:legislation_process, background_color: "#944949", font_color: "#ffffff")
      expect(banner_color?).to eq(true)
    end

    it "background color exist and font color not exist" do
      @process = build(:legislation_process, background_color: "#944949", font_color: "")
      expect(banner_color?).to eq(false)
    end

    it "background color not exist and font color exist" do
      @process = build(:legislation_process, background_color: "", font_color: "#944949")
      expect(banner_color?).to eq(false)
    end

    it "background and font color not exist" do
      @process = build(:legislation_process, background_color: "", font_color: "")
      expect(banner_color?).to eq(false)
    end
  end

  describe "legislation_process_tabs" do
    let(:process) { create(:legislation_process) }
    context "when Admin panel" do
      let(:expected_tabs) do
        {
          "info"           => edit_admin_legislation_process_path(process),
          "homepage"       => edit_admin_legislation_process_homepage_path(process),
          "questions"      => admin_legislation_process_questions_path(process),
          "proposals"      => admin_legislation_process_proposals_path(process),
          "draft_versions" => admin_legislation_process_draft_versions_path(process),
          "milestones"     => admin_legislation_process_milestones_path(process)
        }
      end

      it "returns links to the Admin panel" do
        expect(helper.legislation_process_tabs(process)).to eq(expected_tabs)
      end
    end

    context "when OECD representative panel" do
      let(:expected_tabs) do
        {
          "info"           => edit_oecd_representative_legislation_process_path(process),
          "homepage"       => edit_oecd_representative_legislation_process_homepage_path(process),
          "questions"      => oecd_representative_legislation_process_questions_path(process),
          "proposals"      => oecd_representative_legislation_process_proposals_path(process),
          "draft_versions" => oecd_representative_legislation_process_draft_versions_path(process),
          "milestones"     => oecd_representative_legislation_process_milestones_path(process)
        }
      end

      it "returns links to the Admin panel" do
        expect(helper.legislation_process_tabs(process, :oecd_representative)).to eq(expected_tabs)
      end
    end
  end
end
