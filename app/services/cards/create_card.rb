module Cards
  class CreateCard < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze
    SUCCES_PLASTICAR_CARD = '1001'.freeze

    attribute :store, Object, writer: :private
    attribute :user, ActionController::Parameters, writer: :private

    def initialize(user, store)
      self.store = store
      self.user = user
    end

    def call
      ActiveRecord::Base.transaction do
        card_attributes = ::LamdaServices::CreateUser.new(user, store).call
        request_code = card_attributes["PlasticCardRequestResponse"]["ResponseCode"] unless card_attributes.nil?
        card_default = store.cards.blank?
        card = store.cards.new(
                                card_default: card_default,
                                description: "Tarjeta DataPaga"
                              )

        if request_code == SUCCES_PLASTICAR_CARD
          card.save!
          card.update!(
                        card_id: card_attributes["PlasticCardRequestResponse"]["CardId"],
                        order_id: card_attributes["PlasticCardRequestResponse"]["OrderId"],
                        client_id: card_attributes["PlasticCardRequestResponse"]["ClientId"],
                        merchant_debit: card_attributes["PlasticCardRequestResponse"]["MerchantDebit"]
                      )

          return error(
                        title: ERROR_TITLE,
                        code: 404,
                        message: 'card not be created'
                        ) unless card

          success(card)
        end
      end

      rescue ActiveRecord::RecordInvalid => e
       return error(
                    response: e.record,
                    title: ERROR_TITLE,
                    code: 422,
                    message: 'Card could not be created',
                    errors: e.record.errors
                    )
      rescue => e
      return error(
                    response: e,
                    title: ERROR_TITLE,
                    message: e.message,
                    code: 422
                    )
    end
  end
end
