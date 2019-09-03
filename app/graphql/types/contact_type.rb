class Types::ContactType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: true
  field :owner, Types::UserType, null: false
  field :user, Types::UserType, null: false
end
