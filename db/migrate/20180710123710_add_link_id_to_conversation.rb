class AddLinkIdToConversation < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :link_id, :integer
  end
end
