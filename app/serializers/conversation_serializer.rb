class ConversationSerializer < ActiveModel::Serializer
  attributes :id, :title, :members, :updated_at
  has_many :messages

  def members
    users = object.users.uniq
    users.map { |user| user.short_name }
  end

  def image_url
    # need to connect link to conversation. Then grab image url
  end
end
