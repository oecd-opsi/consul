class Custom::NotificationsMailer < ApplicationMailer
  def new_oecd_representative_request(recipient_id, request_id)
    @recipient = User.find(recipient_id)
    @request = OecdRepresentativeRequest.find(request_id)
    with_user(@recipient) do
      mail(to: @recipient.email, subject: I18n.t("mailers.oecd_representative_request.subject"))
    end
  end

  private

    def with_user(user)
      I18n.with_locale(user.locale) do
        yield
      end
    end
end
