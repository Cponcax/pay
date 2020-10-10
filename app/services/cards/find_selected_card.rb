module Cards
  class FindSelectedCard < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :store, Object, writer: :private

    def initialize(store)
      self.store = store
    end

    def call
      card = store.cards.find_by(card_default: true)
      return error(
        response: card,
          title: ERROR_TITLE,
          code: 404,
          message: 'Card not found'
      ) unless card

      success(card)

    rescue => e
     return error(response: e,
                  title: ERROR_TITLE,
                  message: e.message,
                  code: 422)                  
    end
   end
end
