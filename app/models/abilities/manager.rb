module Abilities
  class Manager
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can :suggest, Budget::Investment

      can :promote_to_oecd_representative, User do |resource|
        resource.persisted? && !resource.administrator? && !resource.oecd_representative?
      end
    end
  end
end
