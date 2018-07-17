class CreateUserNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :user_notifications do |t|
      t.integer :user_id
      t.string :category
      t.integer :category_id
      t.integer :count, :default => 0
    end
  end
end
