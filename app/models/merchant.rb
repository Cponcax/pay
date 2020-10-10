class Merchant < ApplicationRecord
  belongs_to :store
  validates :web_site_url, format: { with: /(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?/ix }
end
