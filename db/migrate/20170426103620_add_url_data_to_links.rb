class AddUrlDataToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :title, :string
    add_column :links, :image, :string
  end
end
