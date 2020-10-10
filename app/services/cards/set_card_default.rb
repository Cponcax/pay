module Cards
  class SetCardDefault < Base
    attribute :store, ActionController::Parameters, writer: :private
    attribute :card_uuid, String, writer: :private

    def initialize(store, card_uuid)
      self.store = store
      self.card_uuid= card_uuid
    end

    def call
      old_card = ::Cards::FindSelectedCard.new(store).call

      if old_card.succeed?
        old_card = old_card.response.update!(card_default: false)
        new_card = ::Cards::FindByUuid.new(card_uuid).call
        new_card.response.update!(card_default: true) if new_card.succeed?
        success(new_card.response)
      else
        old_card
      end

      rescue ActiveRecord::RecordInvalid => e
       return error(response: e.record, title: ERROR_TITLE, code: 422,
                    message: 'Card could not be created', errors: e.record.errors)
      rescue => e
       return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
    end
  end
end
