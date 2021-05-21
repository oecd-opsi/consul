# rubocop:disable Rails/CreateTableWithTimestamps
class CreateOecdRepresentatives < ActiveRecord::Migration[5.1]
  def change
    create_table :oecd_representatives do |t|
      t.references :user, foreign_key: true, index: true
    end
  end
end
# rubocop:enable Rails/CreateTableWithTimestamps
