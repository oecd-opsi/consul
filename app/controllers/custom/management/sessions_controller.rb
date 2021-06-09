require_dependency Rails.root.join("app", "controllers", "management", "sessions_controller").to_s

class Management::SessionsController < ActionController::Base
  def create
    destroy_session
    if admin? || manager? || authenticated_manager?
      redirect_to(session.delete(:return_to) || management_root_path)
    else
      raise CanCan::AccessDenied
    end
  end
end
