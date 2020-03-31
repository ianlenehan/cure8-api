class ChangeGroupFieldname < ActiveRecord::Migration[5.0]
  def change
    rename_column :groups, :group_owner, :owner_id
  end
end
