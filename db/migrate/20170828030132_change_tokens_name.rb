class ChangeTokensName < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :tokens, :tokens_old
  end
end
