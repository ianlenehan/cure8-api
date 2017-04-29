class User < ApplicationRecord
  validates :phone, presence: true
  has_and_belongs_to_many :groups
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

  private

  def hmac_secret
    Rails.application.secrets.hmac_secret
  end

end
