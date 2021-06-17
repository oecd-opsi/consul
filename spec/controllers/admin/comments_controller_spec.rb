require "rails_helper"

describe Admin::CommentsController, type: :controller do
  before { sign_in create(:administrator).user }

  describe "GET export" do
    context "when Process can be found" do
      let(:legislation_process) { create(:legislation_process) }
      let(:question_comment) do
        create(:comment, commentable: create(:legislation_question, process: legislation_process))
      end
      let(:proposal_comment) do
        create(:comment, commentable: create(:legislation_proposal, process: legislation_process))
      end
      let(:expected_filename) do
        "#{legislation_process.title} Comments-#{Time.zone.now.to_formatted_s(:short)}.csv"
      end

      before do
        question_comment
        proposal_comment
        get :export, params: { process_id: legislation_process.id }, format: :csv
      end

      it "sends file as a stream correct response headers" do
        expect(response.headers["Content-Type"]).to eq "application/octet-stream"
      end

      it "sets correct file name" do
        expect(response.headers["Content-Disposition"]).to eq("attachment; filename=#{expected_filename}")
      end

      it "sets correct CSV header and processed comments" do
        expected_body = [Comment.csv_headers, question_comment.for_csv, proposal_comment.for_csv].join

        expect(response.body).to eq expected_body
      end
    end

    context "when Process cannot be found" do
      before do
        get :export, params: { process_id: "not-existing-id" }, format: :csv
      end

      it "redirects back to processes selection page" do
        expect(response).to redirect_to to_export_admin_comments_path
      end

      it "sets correct error notification" do
        expect(flash[:alert]).to eq I18n.t("admin.comments.export.process_missing")
      end
    end
  end
end
