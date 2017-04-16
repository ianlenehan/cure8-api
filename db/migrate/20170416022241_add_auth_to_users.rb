class AddAuthToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :code, :string
    add_column :users, :code_valid, :boolean, :default => false
    add_column :users, :access_token, :string
  end
end
