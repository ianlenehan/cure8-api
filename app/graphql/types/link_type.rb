class Types::LinkType < Types::BaseObject
  field :id, String, null: false
  field :url, String, null: false
  field :title, String, null: false
  field :image, String, null: true
  field :created_at, String, null: false
  field :updated_at, String, null: false
end