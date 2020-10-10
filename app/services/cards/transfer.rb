module Cards
  class Transfer < ::BaseService
    ERROR_TITLE = 'Account Error'.freeze
    SUCCES_CARD_LOAD = '2001'.freeze

    attribute :store,  ActionController::Parameters, writer: :private
    attribute :card_params,  ActionController::Parameters, writer: :private

    def initialize(store, options={})
      self.store = store
      self.card_params = options
    end

    def call
      transaction_id= Transaction.create!(transactionable_type: "card_load").transaction_id
      card = ::Cards::FindByUuid.new(card_params[:card_code]).call
      available_balance = ::Merchants::AvailableBalance.new(store, card_params[:amount]).call

      if card.succeed?
        if available_balance.succeed?
          response = ::Cards::CardLoadByTransfer.new(
                                                      card.response,
                                                      card_params).call

          card_movement = ::AccountMovements::CreateCardMovement.new(
                                                                      card.response,
                                                                      response).call


        if  response[:response_code]
          if response[:response_code] == SUCCES_CARD_LOAD
            merchant_balance = ::Merchants::Balance.new(store, response).call
            card_balance = ::Cards::Balance.new(store, card, response).call if merchant_balance.succeed?
            success(
                      store_balance: merchant_balance.response.balance,
                      card_balance:  card_balance.response.balance,
                      response: "SUCCESS"
                    )
          end
        else
          return error(
            response: "Transaction error",
            title: ERROR_TITLE,
            code: 422,
            message: 'Card Movement ERROR',
            errors: ["Unprocessable Entity"])

        end
        else
          return error(
            title: ERROR_TITLE,
            code: 422,
            message: 'insufficient funds')
        end
      end
    end
  end
end
