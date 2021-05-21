class AddAuthorIdToLegislationProcesses < ActiveRecord::Migration[5.1]
  def change
    add_reference :legislation_processes, :author
  end
end
