module ManagementHelper
  DEFAULT_PERMISSIONS = [:debates, :create_proposals, :support_proposals, :vote_proposals].freeze
  OECD_REPRESENTATIVE_PERMISSIONS = [:collaborative_legislation, :moderation].freeze
  def menu_users?
    ["users", "email_verifications", "document_verifications"].include?(controller_name)
  end

  def menu_edit_password_email?
    controller_name == "account" && action_name == "edit_password_email"
  end

  def menu_edit_password_manually?
    controller_name == "account" && action_name == "edit_password_manually"
  end

  def menu_create_proposal?
    controller_name == "proposals" && action_name == "new"
  end

  def menu_support_proposal?
    controller_name == "proposals" && action_name == "index"
  end

  def menu_print_proposals?
    controller_name == "proposals" && action_name == "print"
  end

  def menu_create_investments?
    (controller_name == "budget_investments" && action_name == "new") ||
    (controller_name == "budgets" && action_name == "create_investments")
  end

  def menu_support_investments?
    (controller_name == "budget_investments" && action_name == "index") ||
    (controller_name == "budgets" && action_name == "support_investments")
  end

  def menu_print_investments?
    (controller_name == "budget_investments" && action_name == "print") ||
    (controller_name == "budgets" && action_name == "print_investments")
  end

  def menu_user_invites?
    controller_name == "user_invites"
  end

  def manager_for_ability
    manager_logged_in
  end

  def permissions_for(user)
    permissions = DEFAULT_PERMISSIONS
    permissions += OECD_REPRESENTATIVE_PERMISSIONS if user.oecd_representative?
    permissions
  end
end
