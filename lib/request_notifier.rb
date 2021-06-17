class RequestNotifier
  def initialize(user, request, action)
    @user = user
    @request = request
    @action = action
  end

  def self.notify!(user, request, action)
    new(user, request, action).notify!
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
      NotificationsMailer.send(
        "#{@action}_oecd_representative_request",
        @user.id,
        @request.id
      ).deliver_later
    end
end
