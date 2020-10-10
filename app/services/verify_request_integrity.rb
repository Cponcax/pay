class VerifyRequestIntegrity

  def initialize(attributes)
  @api_secret_store= attributes[:api_secret]
  @terminal_id =  attributes[:terminal_id]
  end

  def vefiry
    Store.find_by(api_secret_encoded: @api_secret_store)
  end
end
