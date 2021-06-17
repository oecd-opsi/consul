require_dependency Rails.root.join("app", "models", "legislation", "process").to_s

class Legislation::Process < ApplicationRecord
  has_many :annotations, through: :draft_versions, inverse_of: :draft_version
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :legislation_processes

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

  def comments
    Comment.where(commentable_type: "Legislation::Question", commentable_id: question_ids)
      .or(Comment.where(commentable_type: "Legislation::Proposal", commentable_id: proposal_ids))
      .or(Comment.where(commentable_type: "Legislation::Annotation", commentable_id: annotation_ids))
      .includes(:user, :translations, commentable: :process)
  end

  def total_comments
    questions.sum(:comments_count) + proposals.sum(:comments_count) + draft_versions.map(&:total_comments).sum
  end
end
