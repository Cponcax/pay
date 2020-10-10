class Store < ApplicationRecord
  belongs_to :user
  has_many :docs
  has_many :cards, dependent: :destroy
  has_many :transactions ,as: :transactionable
  has_many :account_movements, dependent: :destroy
  has_one :merchant, dependent: :destroy
  accepts_nested_attributes_for :docs, :allow_destroy => true

  validates_presence_of :name,
                        :description,
                        :phone,
                        :phone_country_code,
                        :address_one,
                        :address_two,
                        :city,
                        :state,
                        :country

  validates_uniqueness_of :name, :email, scope: :id

  before_create :generate_uuid, :generate_api_key, :generate_api_secret

  private

  def generate_uuid
    begin
      self.uuid = 'st_' + SecureRandom.hex(15)
    end while !Store.where(uuid: self.uuid).empty?
  end

    def generate_api_key
      begin
        self.api_key = SecureRandom.base64(15).gsub('0','').gsub('l','').gsub('o', '').gsub('O', '').gsub('i','')
      end while !Store.where(api_key: self.api_key).empty?
    end

    def generate_api_secret
      begin
        self.api_secret = SecureRandom.base64(15).gsub('0','').gsub('l','').gsub('o', '').gsub('O', '').gsub('i','')
      end while !Store.where(api_secret: self.api_secret).empty?
    end
end
