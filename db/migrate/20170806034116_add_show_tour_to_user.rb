class AddShowTourToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :show_tour, :boolean, default: false
  end
end
