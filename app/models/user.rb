class User < ApplicationRecord
  validates :phone, presence: true
  has_many :curations
  has_many :contacts
  has_many :push_tokens
  has_many :links, through: :curations
  has_many :tags, through: :curations
  has_many :tokens, dependent: :destroy
  has_many :groups, foreign_key: :owner_id
  has_many :user_notifications, dependent: :destroy
  has_and_belongs_to_many :conversations

  def name
    return '' unless self.first_name
    
    first = self.first_name || ''
    last = self.last_name || ''
    first + ' ' + last
  end

  def short_name
    first = self.first_name || ''
    last = self.last_name.first || ''
    first + ' ' + last
  end

  def active_curations
    curations.where.not(rating: 0).where.not(status: 'deleted')
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
    Group.where(owner_id: self.id)
  end

  def tags
    tags = self.curations.map do |curation|
      curation.tags.map { |tag| tag.name }
    end
    tags.flatten.uniq
  end

  def contacts
    Contact.where(user_id: self.id)
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
