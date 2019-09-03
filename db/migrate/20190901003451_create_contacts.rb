class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.integer :owner_id
      t.integer :user_id
      t.string :name
      t.timestamps
    end
  end
end
