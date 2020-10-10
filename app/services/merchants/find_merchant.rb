module Merchants
  class FindMerchant < ::BaseService
    ERROR_TITLE = 'Merchant Error'.freeze

    attribute :store,  ActionController::Parameters, writer: :private

    def initialize(store, options={})
      self.store = store
    end

    def call
      merchant = store.merchant
      return error(
        title: ERROR_TITLE,
        code: 404,
        message: 'Merchant not found'
        ) unless merchant

      success(merchant)

      rescue => e
       return error(response: e,
                    title: ERROR_TITLE,
                    message: e.message,
                    code: 422)
    end
  end
end
