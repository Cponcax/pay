module Cards
  class List < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :store, Store, writer: :private

    def initialize(store)
      self.store = store
    end

    def call
      cards = Card.list(store)
    return error(
    response: cards,
      title: ERROR_TITLE,
      code: 404,
      message: 'Cards not found'
      ) unless cards

      success(cards)

    rescue => e
     return error(response: e,
                  title: ERROR_TITLE,
                  message: e.message,
                  code: 422)
    end
   end
end
