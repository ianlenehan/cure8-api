class AddFieldsToGroupMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :group_memberships, :user_id, :integer
    add_column :group_memberships, :owner_id, :integer
  end
end
