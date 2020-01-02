class Types::GroupType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: true
  field :owner, Types::UserType, null: false
  field :members, [Types::ContactType], null: false
  field :member_ids, [String], null: false

  def owner
    User.find(object.owner_id)
  end

  def members
    Contact.find(object.member_ids)
  end
end
