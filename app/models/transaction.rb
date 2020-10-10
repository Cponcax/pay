class Transaction < ApplicationRecord
   belongs_to :Transactionable, polymorphic: true, optional: true   
   after_create :generate_transaction_id

   def generate_transaction_id
      self.transaction_id = "%09d" % self.id
      self.save
   end
end
