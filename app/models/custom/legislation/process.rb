require_dependency Rails.root.join("app", "models", "legislation", "process").to_s

class Legislation::Process < ApplicationRecord
  def status_indicator_key
    if in_draft_phase?
      :draft
    else
      status
    end
  end

  def not_started_yet?
    status == :planned
  end

  def in_draft_phase?
    draft_phase.open?
  end
end
