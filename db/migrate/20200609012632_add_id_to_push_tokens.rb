class AddIdToPushTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :push_tokens, :id, :primary_key
  end
end
