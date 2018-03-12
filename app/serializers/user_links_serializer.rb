class UserLinksSerializer < ActiveModel::Serializer
  attributes :curation_id, :link_id, :status, :rating, :date_added, :url,
             :url_type, :title, :image, :comment, :shared_with, :tags, :owner

  def curation_id
    object.id
  end

  def link_id
    object.link_id
  end

  def date_added
    object.created_at
  end

  def url
    link.url
  end

  def url_type
    link.url_type
  end

  def title
    link.title
  end

  def image
    link.image
  end

  def shared_with
    curations = Curation.where(link_id: link.id)
    shared_with = curations.reject { |curation| curation.user_id == link_owner.id }
    shared_with.length
  end

  def owner
    {
      name: link_owner.name,
      phone: link_owner.phone
    }
  end

  private

  def link
    Link.find(object.link_id)
  end

  def link_owner
    User.find(link.link_owner)
  end
end
