class Types::UserType < Types::BaseObject
  field :id, ID, null: false
  field :first_name, String, null: true
  field :last_name, String, null: true
  field :email, String, null: true
  field :phone, String, null: false
  field :image, String, null: false
  field :created_at, String, null: false
  field :updated_at, String, null: false
end
