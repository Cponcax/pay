module Stores
  class CreateStore < ::BaseService
    ERROR_TITLE = 'Store Error'.freeze

    attribute :store_params, Hash, writer: :private
    attribute :merchant_params, Hash, writer: :private
    attribute :user, ActionController::Parameters, writer: :private

    def initialize(user, options={})
      self.store_params = options
      self.merchant_params = options
      self.user = user
    end

    def call
    
      store = user.stores.new(store_params)

      ActiveRecord::Base.transaction do
        store.save!
      end

      merchant = ::Merchants::CreateMerchant.new(
                                                  store,
                                                  user,
                                                  merchant_params
                                                ).call

      if merchant.succeed?
        card = ::Cards::CreateCard.new(
                                        user,
                                        store
                                      ).call
        store.update!(
                        client_id: card.response[:client_id],
                        order_id: card.response[:order_id]
                      )

        return error(
                      title: ERROR_TITLE,
                      code: 404,
                      message: 'Store could not be created'
                    ) unless card

        success(store)
      else
        store.delete
        return error(
                      title: ERROR_TITLE,
                      code: 404,
                      message: 'Store could not be created'
                    )
      end

      rescue ActiveRecord::RecordInvalid => e
        return error(
                      response: e.record,
                      title: ERROR_TITLE,
                      code: 422,
                      message: 'Store could not be created',
                      errors: e.record.errors
                    )

      rescue ActiveRecord::RecordNotUnique  => e
        return error(
                      response: e,
                      title: ERROR_TITLE,
                      message: e.message,
                      code: 422
                    )
    end
  end
end
