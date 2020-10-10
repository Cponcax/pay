module Public
  module Merchants
    class Balance < ::BaseService
      ERROR_TITLE = 'Merchant Error'.freeze

      attribute :store,  ActionController::Parameters, writer: :private
      attribute :merchant_params,  ActionController::Parameters, writer: :private
      attribute :type_request, String, write: :private

      def initialize(store, type_request, options={})
        self.store = store
        self.merchant_params = options
        self.type_request = type_request
      end

      def call
        type = type_request
      case type
      when "charge"
        new_balance = store.merchant.balance + merchant_params.response[:TotalAmount].to_i
        balance = store.merchant.update!(balance: new_balance)
        success(store.merchant)
      when "refund"
        new_balance = store.merchant.balance - merchant_params.response[:TotalAmount].to_i
        balance = store.merchant.update!(balance: new_balance)
        success(store.merchant)
      end

        rescue ActiveRecord::RecordInvalid => e
          return error(response: e.record, title: ERROR_TITLE, code: 422,
                        message: 'Balance could not be created', errors: e.record.errors)
        rescue => e
          return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
      end
    end
  end
end
