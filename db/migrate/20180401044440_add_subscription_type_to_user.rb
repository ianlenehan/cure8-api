class AddSubscriptionTypeToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :subscription_type, :string
  end
end