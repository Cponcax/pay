module Merchants
  class UpdateBalance < ::BaseService
    ERROR_TITLE = 'Merchant Error'.freeze

    attribute :total_amount, String, writer: :private
    attribute :store, Object, writer: :private

    def initialize(total_amount, store)
      self.total_amount = total_amount
      self.store = store
    end

    def call
      balance = store.merchant.balance
      new_balance = balance.to_i + total_amount.to_i

      ActiveRecord::Base.transaction do
        merchant = store.merchant.update!(balance: new_balance.to_s)
      end

      success(store.merchant)

      rescue ActiveRecord::RecordInvalid => e
        return error(response: e.record, title: ERROR_TITLE, code: 422,
                     message: 'Merchant could not be updated', errors: e.record.errors)
      rescue => e
        return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
    end
  end
end
