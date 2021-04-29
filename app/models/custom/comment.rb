require_dependency Rails.root.join("app", "models", "comment").to_s

class Comment < ApplicationRecord
  include Custom::Urlable

  CSV_HEADERS = [
    "ID",
    "Consultation Name",
    "Consultation URL",
    "Author",
    "Type",
    "Full draft Link",
    "Content",
    "URL to Comment",
    "Original Comment",
    "Created at",
    "Total Votes",
    "Total Upvotes",
    "Total Downvotes",
    "Net Votes",
    "Highlighted Text"
  ].freeze

  delegate :process, to: :commentable, prefix: true
  delegate :process_title, to: :commentable, prefix: true
  delegate :name, to: :user, prefix: true

  def self.csv_headers
    CSV.generate_line(CSV_HEADERS)
  end

  def for_csv
    CSV.generate_line(
      [
        id,
        commentable_process_title,
        url_to_process,
        user_name,
        formatted_commentable_type,
        url_to_full_draft,
        body,
        url_to_comment,
        original_comment,
        formatted_created_at,
        total_votes,
        total_likes,
        total_dislikes,
        votes_net,
        highlighted_text
      ]
    )
  end

  def formatted_commentable_type
    commentable_type.constantize.model_name.human
  end

  def formatted_created_at
    created_at.to_formatted_s(:short)
  end

  def url_to_comment
    build_url_for(:polymorphic_url, self.commentable)
  end

  def url_to_process
    build_url_for(:legislation_process_url, commentable_process)
  end

  def url_to_full_draft
    return unless commentable_annotation?

    build_url_for(:legislation_process_draft_version_url,
                  nil,
                  {
                    id:         commentable.legislation_draft_version_id,
                    process_id: commentable_process
                  }
    )
  end

  def original_comment
    return unless ancestors.any?

    parent.body
  end

  def highlighted_text
    return unless commentable_annotation?

    commentable.quote
  end

  def commentable_annotation?
    commentable.is_a?(Legislation::Annotation)
  end

  def votes_net
    total_likes - total_dislikes
  end
end
