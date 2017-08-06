class AddTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :tokens, :string, array: true, default: []
  end
end
