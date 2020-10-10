class DetailAccountMovementSerializer < ActiveModel::Serializer
  attributes  :confirmation_number,
              :transaction_id,
              :total_amount,
              :payment_status,
              :code,
              :description,
              :transaction_time,
              :client_email,
              :street,
              :country,
              :city,
              :zip,
              :region
  def total_amount
    c = AccountMovementSerializer.new(object.itself[:total_amount])
     total = Money.new(c.object, "USD")
     total.format
  end
end
