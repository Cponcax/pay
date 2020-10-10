module Cards
  class FindCardByNumber < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :number, String, writer: :private

    def initialize(number)
      self.number = number
    end

    def call
      card = Card.find_by(card_number: number)
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
