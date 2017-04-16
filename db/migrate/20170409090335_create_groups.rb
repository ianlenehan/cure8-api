class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.text :name
      t.integer :group_owner
      t.timestamps
    end
  end
end
