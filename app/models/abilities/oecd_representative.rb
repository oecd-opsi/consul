module Abilities
  class OecdRepresentative
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can [:create], ::Legislation::Process

      can [:manage], ::Legislation::Process, author_id: user.id
      can [:manage], ::Legislation::DraftVersion, process: { id: user.legislation_process_ids }
      can [:manage], ::Legislation::Question, process: { id: user.legislation_process_ids }
      can [:manage], ::Legislation::Proposal, process: { id: user.legislation_process_ids }

      cannot [:comment_as_moderator, :comment_as_administrator],
             [::Legislation::Process, ::Legislation::DraftVersion,
              Legislation::Question, Legislation::Annotation, Legislation::Proposal]

      can :read, Comment
      can :hide, Comment do |comment|
        comment.commentable_process? && from_managed_process?(user, comment.commentable_process_id) &&
          comment.hidden_at.nil?
      end
      can :ignore_flag, Comment do |comment|
        comment.commentable_process? && from_managed_process?(user, comment.commentable_process_id) &&
          comment.hidden_at.nil? && comment.ignored_flag_at.nil?
      end
      can :moderate, Comment do |comment|
        comment.commentable_process? && from_managed_process?(user, comment.commentable_process_id)
      end
      cannot [:hide, :ignore_flag, :moderate], Comment, user_id: user.id

      cannot [:hide, :ignore_flag, :moderate], Legislation::Proposal
      can :hide, Legislation::Proposal, hidden_at: nil, legislation_process_id: user.legislation_process_ids
      can :ignore_flag, Legislation::Proposal, ignored_flag_at: nil, hidden_at: nil,
          legislation_process_id: user.legislation_process_ids
      can :moderate, Legislation::Proposal, legislation_process_id: user.legislation_process_ids
      cannot [:ignore_flag, :hide, :moderate], Legislation::Proposal, author_id: user.id
    end

    private

      def from_managed_process?(user, process_id)
        user.legislation_process_ids.include?(process_id)
      end
  end
end
