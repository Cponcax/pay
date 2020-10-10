class JwtAuth
  require 'openssl'

  def initialize attributes
    @iat = attributes[:iat]
    @iss = attributes[:iss]
    @name = attributes[:name]
    @token = attributes[:token]
  end

  def call
    begin
      Rails.cache.fetch("client_web", expires: 25.minutes) do
        client_web = ClientWebAuth.find_by(token: @token)
        hmac_secret = client_web.hmac_secret
        decoded_token = JWT.decode client_web.token, hmac_secret, true, { :iss => client_web.iss, :verify_iss => true, :algorithm => 'HS256' }
      end
    rescue JWT::InvalidIssuerError
    rescue StandardError => e
      return nil
    end
  end

  def create
    #Issuer Claim -------
    #The iss (issuer) claim identifies the principal that issued the JWT.
    #The processing of this claim is generally application specific.
    #The iss value is a case-sensitive string containing a StringOrURI value.
    # Use of this claim is OPTIONAL.
    make_hmac_secret
    payload = {
        :iss => "#{@iss}",
        :name => "#{@name}"}

    token = JWT.encode payload, @hmac_secret, 'HS256'

    paylaod_to_create = {
      hmac_secret: @hmac_secret,
      iss: @iss,
      token: token,
      name: @name
    }
    ClientWebAuth.create!(paylaod_to_create)
  end

  def make_hmac_secret
    digest = OpenSSL::Digest.new('sha1')
    @hmac_secret = OpenSSL::HMAC.hexdigest(digest, @iss, @name)
  end

end
