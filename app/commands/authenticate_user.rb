class AuthenticateUser
  prepend SimpleCommand

  def initialize(phone, code)
    @phone = phone
    @code = code
  end

  def call
    fb_service_account = Rails.application.credentials.firebase[:service_account]
    aud = "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit"
    now_seconds = Time.now.to_i

    JsonWebToken.encode({user_id: user.id, uid: user.id, iss: fb_service_account, sub: fb_service_account, aud: aud, iat: now_seconds, exp: now_seconds+(60*60)}) if user
  end

  private

  attr_accessor :phone, :code

  def user
    user = User.find_by(phone: phone)
    
    if user && user.code == code
      user.update(code_valid: false)
      user
    else
      errors.add :user_authentication, 'invalid credentials'
      nil
    end
  end
end