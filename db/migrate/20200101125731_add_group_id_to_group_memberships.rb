class AddGroupIdToGroupMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :group_memberships, :group_id, :integer
  end
end
