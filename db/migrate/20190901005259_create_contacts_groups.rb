class CreateContactsGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts_groups, id: false do |t|
      t.integer :group_id
      t.integer :contact_id
    end
  end
end
