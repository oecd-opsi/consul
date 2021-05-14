module Abilities
  class OecdRepresentative
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can [:manage], ::Legislation::Process
      can [:manage], ::Legislation::DraftVersion
      can [:manage], ::Legislation::Question
      can [:manage], ::Legislation::Proposal
    end
  end
end
