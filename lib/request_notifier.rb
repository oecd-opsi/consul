class RequestNotifier
  def initialize(user, request)
    @user = user
    @request = request
  end

  def self.notify!(user, request)
    new(user, request).notify!
  end

  def notify!
    create_notification
    send_email
  end

  private

    def create_notification
      Notification.add(@user, @request)
    end

    def send_email
      Custom::NotificationsMailer.new_oecd_representative_request(
        @user.id,
        @request.id
      ).deliver_later
    end
end
