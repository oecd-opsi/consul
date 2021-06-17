module Custom::StreamFile
  extend ActiveSupport::Concern
  def stream_file(filename, extension)
    response.headers["Content-Type"] = "application/octet-stream"
    response.headers["Content-Disposition"] = "attachment; filename=#{filename_for(filename, extension)}"
    yield response.stream
  ensure
    response.stream.close
  end

  private

    def filename_for(filename, extension)
      "#{filename}-#{Time.zone.now.to_formatted_s(:short)}.#{extension}"
    end
end
