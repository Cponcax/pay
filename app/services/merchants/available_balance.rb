module Merchants
  class AvailableBalance < ::BaseService
    ERROR_TITLE = 'Merchant Error'.freeze

    attribute :store,  ActionController::Parameters, writer: :private
    attribute :amount,  String, writer: :private

    def initialize(store, amount)
      self.store = store
      self.amount = amount.to_f * 100
    end

    def call
      merchant = store.merchant.balance.to_f >=  amount.to_f
      if merchant
       success(merchant)

      else
        return error(
          title: ERROR_TITLE,
          code: 404,
          message: 'insufficient funds')
      end
    end
  end
end
