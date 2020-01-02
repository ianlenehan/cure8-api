class CreateJoinTableGroupsMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :groups_members, :id => false do |t|
      t.integer :group_id
      t.integer :member_id
    end
  end
end
