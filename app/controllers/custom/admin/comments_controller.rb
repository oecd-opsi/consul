class Admin::CommentsController < Admin::BaseController
  include Custom::StreamFile

  def index
    @comments = Comment.sort_by_newest.page(params[:page])
  end

  def to_export
    @processes = ::Legislation::Process.page(params[:page])
  end

  def export
    @process = ::Legislation::Process.find(params[:process_id])
    respond_to do |format|
      format.csv { stream_csv_report }
    end
  end

  private

    def stream_csv_report
      stream_file("#{@process.title} Comments", "csv") do |stream|
        stream.write Comment.csv_headers
        @process.comments.find_each do |comment|
          stream.write comment.for_csv
        end
      end
    end
end
