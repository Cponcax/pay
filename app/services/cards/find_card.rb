module Cards
  class FindCard < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :uuid, String, writer: :private
    attribute :store, Object, writer: :private

    def initialize(store, uuid)
      self.uuid = uuid
      self.store = store
    end

    def call
    card = store.cards.find_by(uuid: uuid)
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
