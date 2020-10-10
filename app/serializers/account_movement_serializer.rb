class AccountMovementSerializer < ActiveModel::Serializer
  attributes  :uuid, :confirmation_number, :total_amount,  :client_email, :payment_status, :description, :created_date

  def total_amount
    object.total.format
  end
end
