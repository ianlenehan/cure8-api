class RenameTypeToUrlType < ActiveRecord::Migration[5.0]
  def change
    rename_column :links, :type, :url_type
  end
end
