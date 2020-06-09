class CreatePushTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :push_tokens do |t|
      t.string :token
      t.boolean :notify, default: true
      t.boolean :notify_new_link, default: true
      t.boolean :notify_new_rating, default: true
      t.boolean :notify_new_message, default: true
    end
  end
end
