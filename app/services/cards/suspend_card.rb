module Cards
  class SuspendCard < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :card, ActionController::Parameters, writer: :private


    def initialize(card)
      self.card = card
    end

    def call
      card.update!(suspended: true)
      success(card)

      rescue ActiveRecord::RecordInvalid => e
        return error(response: e.record, title: ERROR_TITLE, code: 422,
                     message: 'Card could not be created', errors: e.record.errors)
      rescue => e
        return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
    end
  end
end
