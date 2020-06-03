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
  field :shared_with, [Types::UserType], null: true

  def link
    Link.find(object.link_id)
  end

  def curator_name
    User.find(object.curator_id).name
  end

  def tags
    object.tags
  end

  def shared_with
    curations = Curation.where(link_id: object.link_id)
    user_ids = curations.pluck(:user_id)
    user_ids_without_current_user = user_ids.reject { |id| id === current_user.id }
    begin
      ids = user_ids_without_current_user.map { |id| User.find(id) }.uniq
    rescue StandardError => e
      print "Not Found Error: #{e}"
    end
    User.where(id: ids)
  end

  private

  def current_user
    context[:current_user]
  end
end
