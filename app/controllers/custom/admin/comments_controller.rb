class Admin::CommentsController < Admin::BaseController
  include Custom::StreamFile
  before_action :fetch_process, only: :export

  def index
    @comments = Comment.sort_by_newest.page(params[:page])
  end

  def to_export
    @processes = ::Legislation::Process.page(params[:page])
  end

  def export
    respond_to do |format|
      format.csv { stream_csv_report }
    end
  end

  private

    def fetch_process
      @process = ::Legislation::Process.find_by(id: params[:process_id])
      return unless @process.nil?

      redirect_to to_export_admin_comments_path, alert: t("admin.comments.export.error")
    end

    def stream_csv_report
      stream_file("#{@process.title} Comments", "csv") do |stream|
        stream.write Comment.csv_headers
        @process.comments.find_each do |comment|
          stream.write comment.for_csv
        end
      end
    end
end
