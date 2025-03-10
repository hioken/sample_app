class CreateChannels < ActiveRecord::Migration[7.0]
  def change
    create_table :channels do |t|
      t.datetime :last_message_at, null: false

      t.timestamps
    end
    add_index :channels, :last_message_at
  end
end
