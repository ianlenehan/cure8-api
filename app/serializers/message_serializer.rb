class MessageSerializer < ActiveModel::Serializer
  attributes :id, :conversation_id, :text, :created_at, :user_id, :user

  def user
    u = User.find(object.user_id)

    { _id: object.user_id, name: u.name }
  end
end
