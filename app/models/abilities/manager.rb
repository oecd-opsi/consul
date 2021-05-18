module Abilities
  class Manager
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can :suggest, Budget::Investment

      can :promote_to_oecd_representative, User do |resource|
        resource.persisted? && resource.standard_user?
      end

      can [:read], OecdRepresentativeRequest
      can [:accept, :reject], OecdRepresentativeRequest do |request|
        request.status.pending? && !request.user_oecd_representative?
      end

      merge Abilities::Moderation.new(user)

      can :comment_as_moderator, [Debate, Comment, Proposal, Budget::Investment, Poll::Question,
                                  Legislation::Question, Legislation::Annotation, Legislation::Proposal, Topic]
    end
  end
end
