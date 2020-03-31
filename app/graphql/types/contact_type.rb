class Types::ContactType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: true
  field :linked_user, Types::UserType, null: false
  field :user, Types::UserType, null: false

  def linked_user
    User.find(object.linked_user_id)
  end
end
