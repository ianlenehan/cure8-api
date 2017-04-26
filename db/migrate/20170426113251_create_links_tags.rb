class CreateLinksTags < ActiveRecord::Migration[5.0]
  def change
    create_table :links_tags, :id => false do |t|
      t.integer :link_id
      t.integer :user_id
    end
  end
end
