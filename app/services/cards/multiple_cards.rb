module Cards
  class MultipleCards < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :user_id, Integer, writer: :private
    attribute :store_uuid, String, writer: :private
    attribute :number_cards_requested, Integer, writer: :private

    def initialize(user_id, store_uuid, number_cards_requested)
      self.store_uuid = store_uuid
      self.user_id = user_id
      self.number_cards_requested = number_cards_requested
    end

    def call
      cards = CreateMultipleCards.perform_async(user_id, store_uuid, number_cards_requested)

    rescue ActiveRecord::RecordInvalid => e
     return error(response: e.record, title: ERROR_TITLE, code: 422,
                  message: 'Card could not be created', errors: e.record.errors)
    rescue => e
     return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
    end
   end
end
