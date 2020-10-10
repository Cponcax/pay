class BalanceSerializer < ActiveModel::Serializer
  attributes  :balance

  def balance
    total = Money.new(object.balance, "USD")
    total.format
  end
end
