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
    end
  end
end
