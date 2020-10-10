class CreateApiSecret

  def initialize(attributes)
    @api_secret_store= attributes[:api_secret]
    @terminal_id =  attributes[:terminal_id]
  end

  def call
    api_secret_encoded = Base64.encode64(OpenSSL::HMAC.digest('sha256', @terminal_id, @api_secret_store)).strip
  end
end
