class AddMemberIdBackToGroupsUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :groups_users, :member_id, :integer
  end
end
