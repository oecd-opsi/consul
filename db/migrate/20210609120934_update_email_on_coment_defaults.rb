class UpdateEmailOnComentDefaults < ActiveRecord::Migration[5.1]
  def up
    change_table :users do |t|
      t.change :email_on_comment, :boolean, default: true
      t.change :email_on_comment_reply, :boolean, default: true
    end
  end

  def down
    change_table :users do |t|
      t.change :email_on_comment, :boolean, default: false
      t.change :email_on_comment_reply, :boolean, default: false
    end
  end
end
