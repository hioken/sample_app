class CreateConversationUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :conversation_users do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :last_read_message_id, null: false, default: 1
      t.boolean :is_left, null: false, default: false
      t.timestamps
      t.index [:conversation_id, :user_id], unique: true, name: 'index_conversation_users_on_conversation_id_and_user_id'
    end
  end
end
