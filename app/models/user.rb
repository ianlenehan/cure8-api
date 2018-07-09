class User < ApplicationRecord
  validates :phone, presence: true
  has_many :curations
  has_many :links, through: :curations
  has_many :tags, through: :curations
  has_many :tokens, dependent: :destroy
  has_and_belongs_to_many :conversations

  def name
    first = self.first_name || ''
    last = self.last_name || ''
    first + ' ' + last
  end

  def authenticate(code)
    self.generate_access_token if self.code_valid && self.code == code
  end

  def generate_access_token
    payload = { :id => self.id, :time => Time.now }
    token = JWT.encode payload, hmac_secret, 'HS256'
    self.tokens.create(token: token, token_type: 'auth')
    token
  end

  # TODO this is only used for v1 of links api
  def links
    curations = self.curations.select do |curation|
      curation.rating != '0' and curation.status != 'deleted'
    end

    links = curations.map do |curation|
      link = Link.find(curation.link_id)
      owner = User.find(link.link_owner)
      link_for_app = {
        curation_id: curation.id,
        link_id: link.id,
        status: curation.status,
        rating: curation.rating,
        date_added: curation.created_at,
        url: link.url,
        url_type: link.url_type,
        title: link.title,
        image: link.image,
        comment: curation.comment,
        shared_with: people_shared_with(link, owner),
        tags: curation.tags,
        owner: {
          name: owner.name,
          phone: owner.phone,
        }
      }
      link_for_app
    end
    links.sort_by { |link| link[:date_added] }.reverse
  end

  def groups
    Group.where(group_owner: self.id)
  end

  def tags
    tags = self.curations.map do |curation|
      curation.tags.map { |tag| tag.name }
    end
    tags.flatten.uniq
  end

  def contacts
    contacts = self.groups.map do |group|
      if group.user_id
        contact = User.find(group.user_id)
        {
          name: group.name,
          phone: contact.phone,
          id: group.id,
          member: group.is_member?,
          updated_at: group.updated_at
        }
      end
    end
    contacts.compact.sort_by { |contact| contact[:name] }
  end

  def contact_groups
    contact_groups = self.groups.select { |group| group.members }
    sorted_groups = contact_groups.sort_by { |group| group.name }
    sorted_groups.map do |group|
      members = get_members(group)
      { id: group.id, name: group.name, members: members }
    end
  end

  def stats
    links = Link.where(link_owner: self.id)
    curations = links.map { |link| link.archived_curations.count }
    ratings = links.map do |link|
      link.curations.map do |curation|
        curation.rating.to_f if curation.rating
      end
    end
    curation_count = curations.reduce(:+) || 0
    rating_count = ratings.flatten.compact.reduce(:+) || 0
    archived_count = ratings.flatten.compact.count || 0
    if rating_count > 0
      score = (rating_count / archived_count).round(2)
    else
      score = 0
    end
    { curations: curation_count, score: score, archived: archived_count, ratings: rating_count }
  end

  def push_tokens
    self.tokens.where(token_type: 'push')
  end

  def auth_tokens
    self.tokens.where(token_type: 'auth')
  end

  def bookmarklet_code
    phone_code = phone.slice(-4..-1)
    "#{phone_code}-#{id}"
  end

  private

  # TODO this is only used for v1 of links api
  def people_shared_with(link, owner)
    curations = Curation.where(link_id: link.id)
    shared_with = curations.select { |curation| curation.user_id != owner.id }
    shared_with.length
  end

  def hmac_secret
    Rails.application.secrets.hmac_secret
  end

  def get_members(group)
    group.members.map do |member_id|
      member = Group.find(member_id)
      { name: member.name, id: member.user_id, group_id: member.id }
    end
  end

end
