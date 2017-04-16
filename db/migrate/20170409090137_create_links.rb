class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.text :url
      t.string :type
      t.integer :link_owner
      t.text :comment
      t.timestamps
    end
  end
end
