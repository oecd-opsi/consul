class CustomDeviseFailureApp < Devise::FailureApp
  def redirect_url
    return super unless Setting["feature.auth0_login"]

    :root
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
