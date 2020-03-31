class AddMemberIdsToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :member_ids, :text, array: true, default: []
  end
end
