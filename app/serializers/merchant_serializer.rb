class MerchantSerializer < ActiveModel::Serializer
  attributes  :balance

  def balance
    total = Money.new(object.response.balance, "USD")
    total.format
  end
end
