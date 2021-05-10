module Abilities
  class Manager
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can :suggest, Budget::Investment

      can :promote_to_oecd_representative, User do |resource|
        resource.persisted? && resource.standard_user?
      end
    end
  end
end
