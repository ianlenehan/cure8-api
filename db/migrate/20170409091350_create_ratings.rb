class CreateRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :ratings do |t|
      t.integer :rating
      t.integer :rated_by
      t.timestamps
    end
  end
end
