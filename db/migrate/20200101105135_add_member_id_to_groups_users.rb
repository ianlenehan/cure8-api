class AddMemberIdToGroupsUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :groups_users, :member_id, :integer
    remove_column :groups_users, :user_id, :integer
  end
end
