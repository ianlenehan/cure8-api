class RemoveLinkedOwnerIdFromContacts < ActiveRecord::Migration[5.2]
  def change
    remove_column :contacts, :linked_owner_id, :integer
    remove_column :contacts, :owner_id, :integer
  end
end
