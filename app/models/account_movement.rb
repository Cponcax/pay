class AccountMovement < ApplicationRecord
  belongs_to :store
  after_create :set_created_date

  monetize :total_amount, :as => "total"

  before_create :generate_uuid

  APPROVED = "APPROVED".freeze

  private

  def self.account_movement_approved
    where(payment_status: APPROVED)
  end

  def set_created_date
    self.update(created_date: Time.zone.today)
  end

  def generate_uuid
    begin
      self.uuid = 'am_' + SecureRandom.hex(15)
    end while !Store.where(uuid: self.uuid).empty?
  end

end
