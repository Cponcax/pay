module AccountMovements
  class CreateCardMovement < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :card,  ActionController::Parameters, writer: :private
    attribute :params,  ActionController::Parameters, writer: :private

    def initialize(card, options={})
      self.card = card
      self.params = options
    end

    def call
      account_movement = card.card_movements.new(
                                                  order_id: card[:order_id],
                                                  card_id: card[:card_id],
                                                  client_id: params[:client_id],
                                                  total_amount: params[:amount],
                                                  response_code: params[:response_code],
                                                  response_txt: params[:response_txt],
                                                  transaction_id: params[:transaction_id])
      account_movement.save!
      return error(
        title: ERROR_TITLE,
        code: 404,
        message: "Card Movement could not be created"
        ) unless account_movement

      success(account_movement)

     rescue ActiveRecord::RecordInvalid => e
       return error(response: e.record, title: ERROR_TITLE, code: 422,
                    message: 'Card Movement could not be created', errors: e.record.errors)
     rescue => e
       return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
     end
   end
end
