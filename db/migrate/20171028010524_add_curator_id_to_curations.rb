class AddCuratorIdToCurations < ActiveRecord::Migration[5.0]
  def change
    add_column :curations, :curator_id, :integer
  end
end
