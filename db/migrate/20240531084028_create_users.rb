class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :unique_id
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :remember_digest
      t.string :activation_digest
      t.string :reset_digest
      t.boolean :activated, default: false
      t.boolean :is_deleted, default: false
      t.boolean :admin, default: false
      t.datetime :activated_at
      t.datetime :reset_sent_at

      t.timestamps
    end
  end
end
