class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :notifications, :boolean, :default => true
    add_column :users, :notifications_new_link, :boolean, :default => true
    add_column :users, :notifications_new_rating, :boolean, :default => true
  end
end
