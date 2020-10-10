class Doc < ApplicationRecord
  belongs_to :store
  mount_base64_uploader :document, DocumentUploader
  before_create :generate_uuid
  has_many :transactions ,as: :transactionable
  # validates_presence_of :uuid
  attr_accessor :document_data
  # serialize :documents, JSON
  validates_presence_of :name

  def generate_uuid
    begin
      self.uuid = 'do_' + SecureRandom.hex(15)
    end while !User.where(uuid: self.uuid).empty?
  end
end
