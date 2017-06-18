class User < ApplicationRecord
  validates :phone, presence: true
  has_many :curations
  has_many :links, through: :curations

  def name
    self.first_name + ' ' + self.last_name
  end

  def authenticate(code)
    self.generate_access_token if self.code_valid && self.code == code
  end

  def generate_access_token
    payload = { :id => self.id }
    token = JWT.encode payload, hmac_secret, 'HS256'
    self.update(access_token: token)
    token
  end

  def destroy_access_token
    self.access_token = nil
  end

  def links
    links = []
    self.curations.each do |curation|
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
        comment: link.comment,
        owner: {
          name: owner.name,
          phone: owner.phone,
        }
      }
      links.push(link_for_app)
    end
    links
  end

  def groups
    Group.where(group_owner: self.id)
  end

  def contacts
    contacts = self.groups.map do |group|
      if group.members.length == 1
        contact = User.find(group.members.first)
        { name: group.name, phone: contact.phone, id: group.id }
      end
    end
    contacts.compact.sort_by do |contact|
      contact[:name]
    end
  end

  def contact_groups
    contact_groups = self.groups.select { |group| group.members.length > 1 }
    sorted_groups = contact_groups.sort_by { |group| group.name }
    sorted_groups.map do |group|
      members = get_members(group)
      { id: group.id, name: group.name, members: members }
    end
  end

  private

  def hmac_secret
    Rails.application.secrets.hmac_secret
  end

  def get_members(group)
    group.members.map do |member_id|
      member = Group.find(member_id)
      { name: member.name, id: member_id }
    end
  end

end
