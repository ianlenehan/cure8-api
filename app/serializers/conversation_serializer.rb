class ConversationSerializer < ActiveModel::Serializer
  attributes :id, :title, :members, :last_update
  has_many :messages

  def members
    users = object.users.uniq
    users.map { |user| user.short_name  }
  end

  def image_url
    # need to connect link to conversation. Then grab image url
  end

  def last_update
    object.messages.length > 0 ? object.messages.last.created_at : object.created_at
  end
end
