module Merchants
  class Balance < ::BaseService
    ERROR_TITLE = 'Merchant Error'.freeze

    attribute :store,  ActionController::Parameters, writer: :private
    attribute :merchant_params,  ActionController::Parameters, writer: :private

    def initialize(store, options={})
      self.store = store
      self.merchant_params = options

    end

    def call
      
      balance = store.merchant.merchant_balance.to_i -  merchant_params[:merchant_debit].to_i
      merchant_balance = store.merchant.update!(merchant_balance: balance)
      success(store.merchant)

      rescue ActiveRecord::RecordInvalid => e
        return error(response: e.record, title: ERROR_TITLE, code: 422,
                      message: 'Balance could not be created', errors: e.record.errors)
      rescue => e
        return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
    end
  end
end
