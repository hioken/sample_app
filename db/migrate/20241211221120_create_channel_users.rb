class CreateChannelUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_users do |t|
      t.references :channel, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :last_read_message_id, null: false, default: 1
      t.boolean :is_left, null: false, default: false
      t.timestamps
      t.index [:channel_id, :user_id], unique: true, name: 'index_channel_users_on_channel_id_and_user_id'
    end
  end
end
