class NotificationsMailer < ApplicationMailer
  def new_oecd_representative_request(recipient_id, request_id)
    fetch_resources(recipient_id, request_id)
    with_user(@recipient) do
      mail(to: @recipient.email, subject: I18n.t("mailers.new_oecd_representative_request.subject"))
    end
  end

  def accepted_oecd_representative_request(recipient_id, request_id)
    fetch_resources(recipient_id, request_id)
    with_user(@recipient) do
      mail(to: @recipient.email, subject: I18n.t("mailers.accepted_oecd_representative_request.subject"))
    end
  end

  def rejected_oecd_representative_request(recipient_id, request_id)
    fetch_resources(recipient_id, request_id)
    with_user(@recipient) do
      mail(to: @recipient.email, subject: I18n.t("mailers.rejected_oecd_representative_request.subject"))
    end
  end

  private

    def with_user(user)
      I18n.with_locale(user.locale) do
        yield
      end
    end

    def fetch_resources(recipient_id, request_id)
      @recipient = User.find(recipient_id)
      @request = OecdRepresentativeRequest.find(request_id)
    end
end
