class CreateConversationsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations_users do |t|
      t.integer :conversation_id
      t.integer :user_id
    end
  end
end
