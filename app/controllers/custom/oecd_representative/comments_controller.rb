class OecdRepresentative::CommentsController < OecdRepresentative::BaseController
  include Custom::StreamFile
  before_action :fetch_process, only: :export

  def index
    @comments = Comment.for_processes(current_user.legislation_process_ids)
                  .sort_by_newest
                  .page(params[:page])
  end

  def to_export
    @processes = current_user.legislation_processes.page(params[:page])
  end

  def export
    respond_to do |format|
      format.csv { stream_csv_report }
    end
  end

  private

    def fetch_process
      @process = current_user.legislation_processes.find_by(id: params[:process_id])
      return unless @process.nil?

      redirect_to to_export_oecd_representative_comments_path,
                  alert: t("admin.comments.export.process_missing")
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
