module Cards
  class Balance < ::BaseService
    ERROR_TITLE = 'Merchant Error'.freeze

    attribute :store,  ActionController::Parameters, writer: :private
    attribute :card,  ActionController::Parameters, writer: :private
    attribute :card_params,  ActionController::Parameters, writer: :private

    def initialize(store, card, options={})
      self.store = store
      self.card_params = options
      self.card = card.response
    end

    def call
      balance = card.card_balance.to_i + card_params[:merchant_debit].to_i
      card_balance = card.update!(card_balance: balance)
      success(card)

      rescue ActiveRecord::RecordInvalid => e
        return error(response: e.record, title: ERROR_TITLE, code: 422,
                      message: 'Card could not be created', errors: e.record.errors)
      rescue => e
        return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
    end
  end
end
