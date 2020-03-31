class RemoveMembersFieldFromGroups < ActiveRecord::Migration[5.2]
  def change
    remove_column :groups, :members, :integer
  end
end
