class CreateCurations < ActiveRecord::Migration[5.0]
  def change
    create_table :curations do |t|
      t.integer :user_id
      t.integer :link_id
      t.string :rating
      t.string :status, :default => 'new'
      t.timestamps
    end
  end
end
