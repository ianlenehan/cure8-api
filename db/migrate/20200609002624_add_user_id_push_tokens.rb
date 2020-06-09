class AddUserIdPushTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :push_tokens, :user_id, :integer
  end
end
