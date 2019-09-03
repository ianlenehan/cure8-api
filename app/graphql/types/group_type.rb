class Types::GroupType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: true
  field :owner, Types::UserType, null: false
  field :members, [Types::ContactType], null: false
end
