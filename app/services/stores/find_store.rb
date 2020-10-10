module Stores
  class FindStore < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :id, Integer, writer: :private

    def initialize(store, id)
      self.id = id
      self.store = store
    end

    def call
    card = store.cards.find_by(id: id)
    return error(
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
