class User < ApplicationRecord
  validates :phone, presence: true
  has_and_belongs_to_many :groups
  has_many :links, through: :curations

  def name
    self.first_name + ' ' + self.last_name
  end

  private

  def generate_access_token
    payload = {:id => self.id}
    self.access_token = JWT.encode payload, hmac_secret, 'HS256'
    save
  end

  def destroy_access_token
    self.access_token = nil
  end

  def hmac_secret
    Rails.application.secrets.hmac_secret
  end

end
