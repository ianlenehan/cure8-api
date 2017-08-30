class ChangeTokenTypeColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :tokens, :type, :token_type
  end
end
