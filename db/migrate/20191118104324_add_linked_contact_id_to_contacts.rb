class AddLinkedContactIdToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :linked_owner_id, :integer
  end
end
