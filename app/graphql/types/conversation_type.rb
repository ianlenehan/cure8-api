class Types::ConversationType < Types::BaseObject
  field :id, String, null: false
  field :title, String, null: false
  field :created_at, String, null: false
  field :updated_at, String, null: false
  field :users, [Types::UserType], null: false
end