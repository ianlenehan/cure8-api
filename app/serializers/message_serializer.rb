class MessageSerializer < ActiveModel::Serializer
  attributes :id, :conversation_id, :text, :created_at, :user_id, :user, :conversation

  def user
    u = User.find(object.user_id)

    { _id: object.user_id, name: u.name }
  end

  def conversation
    {
      id: object.conversation.id,
      updated_at: object.conversation.updated_at,
      unread_messages: unread_messages(object.conversation)
    }
  end

  def unread_messages(conversation)
    unread = UserNotification.find_by(
      user_id: object.user_id
      category: 'conversation',
      category_id: conversation.id
    )
    unread ? unread.count : 0
  end
end
