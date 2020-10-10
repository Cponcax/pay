module Cards
  class FindByUuid < Base
    attribute :uuid, String, writer: :private

    def initialize(uuid)
      self.uuid = uuid
    end

    def call
      card = Card.find_by(uuid: uuid)
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
