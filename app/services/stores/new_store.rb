module Stores
  class NewStore < ::BaseService
    ERROR_TITLE = 'Store Error'.freeze

    attribute :store_params, Hash, writer: :private
    attribute :merchant_params, Hash, writer: :private
    attribute :user, ActionController::Parameters, writer: :private
    attribute :store, ActionController::Parameters, writer: :private

    def initialize(user, store, options={})
      self.user = user
      self.store = store
      self.store_params = options
      self.merchant_params = options
    end

    def call
      new_store = user.stores.new(store_params)
      ActiveRecord::Base.transaction do
        new_store.save!
      end

      merchant = ::Merchants::NewMerchant.new(
                                                store,
                                                new_store,
                                                user,
                                                merchant_params
                                              ).call

      if  merchant.succeed?
        card = ::Cards::NewCard.new(
                                      user,
                                      store,
                                      new_store
                                    ).call
        new_store.update!(
                            client_id: card.response[:client_id],
                            order_id: card.response[:order_id]
                          )
        return error(
                      title: ERROR_TITLE,
                      code: 404,
                      message: 'Store could not be created'
                    ) unless card

          success(new_store)
      else
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
