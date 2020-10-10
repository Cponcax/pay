class CardSerializer < ActiveModel::Serializer
  attributes  :id, :uuid, :status, :expiration_date, :emboss_name, :card_number, :order_status, :card_id, :card_default,
              :balance, :description, :type_of_transfer, :days, :suspended

  def balance
    c = AccountMovementSerializer.new(object.itself[:total_amount])
     total = Money.new(c.object, "USD")
     total.format
  end
end
