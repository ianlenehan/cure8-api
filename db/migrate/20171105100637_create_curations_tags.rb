class CreateCurationsTags < ActiveRecord::Migration[5.0]
  def change
    create_table :curations_tags, id: false do |t|
      t.integer :curation_id
      t.integer :tag_id
    end
  end
end
