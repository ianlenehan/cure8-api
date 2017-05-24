class RemoveMembersFromGroups < ActiveRecord::Migration[5.0]
  def change
    remove_column :groups, :members, :string
  end
end
