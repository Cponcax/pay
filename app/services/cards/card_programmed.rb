module Cards
  class CardProgrammed < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze
    DEFAULT_DAYS = "3".freeze

    attribute :store, Object, writer: :private
    attribute :card_params, ActionController::Parameters, writer: :private

    def initialize(store, options={})
      self.store = store
      self.card_params = options
    end

    def call
      card = FindSelectedCard.new(store).call
      if card_params[:type_of_transfer]
        card.response.update!(card_params)
      else
        card.response.update!(type_of_transfer: false,
                              days: DEFAULT_DAYS)
      end

      success(card.response)

    rescue ActiveRecord::RecordInvalid => e
     return error(response: e.record,
                  title: ERROR_TITLE,
                  code: 422,
                  message: 'Card could not be updated',
                  errors: e.record.errors)
    rescue => e
     return error(response: e,
                  title: ERROR_TITLE,
                  message: e.message,
                  code: 422)
    end
   end
end
