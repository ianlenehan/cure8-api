class ConversationSerializer < ActiveModel::Serializer
  attributes :id, :title, :members, :updated_at, :unread_messages
  has_many :messages

  def members
    users = object.users.uniq
    users.map do |user|
      user.short_name if user.first_name
    end
  end

  def image_url
    # need to connect link to conversation. Then grab image url
  end

  def unread_messages
    current_user = @instance_options[:user]

    if current_user
      unread = UserNotification.find_by(
        user_id: current_user.id,
        category: 'conversation',
        category_id: object.id
      )
      unread ? unread.count : 0
    else
      0
    end
  end
end
