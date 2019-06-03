class Types::ProfileType < Types::BaseObject
  field :url, String, null: false
  field :url_type, String, null: false
  field :comment, String, null: false
  field :title, String, null: false
  field :image, String, null: false
  field :created_at, String, null: false
  field :updated_at, String, null: false
end