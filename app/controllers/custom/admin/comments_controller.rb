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
      query         = @process.comments_sql_for_csv
      query_options = "WITH CSV"

      stream_file("#{@process.title} Comments", "csv") do |stream|
        stream.write "ID, Content, Author, Type\n"
        Comment.stream_query_rows(query, query_options) do |row_from_db|
          stream.write row_from_db
        end
      end
    end
end
