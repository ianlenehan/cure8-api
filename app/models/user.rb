class User < ApplicationRecord
  validates :phone, presence: true
  has_and_belongs_to_many :groups
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

  private

  def hmac_secret
    Rails.application.secrets.hmac_secret
  end

end
