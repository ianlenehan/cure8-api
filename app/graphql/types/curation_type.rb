class Types::CurationType < Types::BaseObject
  field :id, ID, null: false
  field :link, Types::LinkType, null: false
  field :rating, String, null: true
  field :status, String, null: false
  field :comment, String, null: true
  field :curator_id, String, null: false
  field :created_at, String, null: false
  field :curator_name, String, null: false
  field :tags, [Types::TagType], null: false

  def link
    Link.find(object.link_id)
  end

  def curator_name
    User.find(object.curator_id).name
  end

  def tags
    object.tags
  end
end
