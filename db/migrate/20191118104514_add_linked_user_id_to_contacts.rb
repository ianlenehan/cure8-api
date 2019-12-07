class AddLinkedUserIdToContacts < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :linked_user_id, :integer
  end
end
