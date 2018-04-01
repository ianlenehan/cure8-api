class AddLastLoginToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_login, :date
  end
end
