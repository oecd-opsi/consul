class OecdRepresentative::Moderation::CommentsController < OecdRepresentative::Moderation::BaseController
  has_filters %w[pending_flag_review all with_ignored_flag], only: :index
  has_orders %w[flags newest], only: :index

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  private

    def load_resources
      @resources = Comment.for_processes(current_user.legislation_process_ids)
    end

    def resource_model
      Comment
    end

    def author_id
      :user_id
    end
end
