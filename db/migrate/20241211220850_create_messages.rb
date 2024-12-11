class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :user_id, null: false, foreign_key: true
      t.references :channel_id, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end
