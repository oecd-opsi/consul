class CreateOecdRepresentativeRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :oecd_representative_requests do |t|
      t.references :user
      t.string :status
      t.text :message
      t.timestamps
    end
  end
end
