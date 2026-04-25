class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.datetime :last_message_at, null: false

      t.timestamps
    end
    add_index :conversations, :last_message_at
  end
end
