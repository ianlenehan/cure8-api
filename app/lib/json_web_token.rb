class JsonWebToken
  class << self
    def encode(payload)
      @rsa_private = OpenSSL::PKey::RSA.new Rails.application.credentials.firebase[:private_key]

      JWT.encode(payload, @rsa_private, "RS256")
    end
 
    def decode(token)
      @rsa_private = OpenSSL::PKey::RSA.new Rails.application.credentials.firebase[:private_key]
      @rsa_public = @rsa_private.public_key

      leeway = 15552000 # 6 months
      body = JWT.decode(token, @rsa_public, true, { :leeway => leeway, :algorithm => 'RS256' })[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
 end