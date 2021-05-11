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
    end
  end
end
