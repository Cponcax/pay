class Card < ApplicationRecord
  belongs_to :store
  has_many :transactions, as: :transactionable
  has_many :card_movements
  before_create :generate_uuid
  before_create :default_balance
  #
  validates_presence_of :card_id,
                        :merchant_debit

  validates_uniqueness_of :card_id, :allow_nil => false, scope: :id

  private

  def self.list(store)
    cards = store.cards
    unless store.cards == []
        return cards
    else
      return nil
    end
  end

  def default_balance
    self.balance = "0"
  end


  def generate_uuid
    begin
      self.uuid  = 'cd_' + SecureRandom.hex(15)
    end while !Card.where(uuid: self.uuid).empty?
  end
end
