class AddCommentToCurations < ActiveRecord::Migration[5.0]
  def change
    add_column :curations, :comment, :text
  end
end
