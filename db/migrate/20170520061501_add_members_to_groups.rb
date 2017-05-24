class AddMembersToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :members, :integer, array: true
  end
end
