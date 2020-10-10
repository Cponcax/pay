class UpdateKyc
  def initialize att
    @store = att[:store]
  end

  def call
    @store.update_attributes(kyc: true)
  end
end
