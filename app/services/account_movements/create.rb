module AccountMovements
  class Create < ::BaseService
    ERROR_TITLE = 'Card Error'.freeze

    attribute :store,  ActionController::Parameters, writer: :private
    attribute :params,  ActionController::Parameters, writer: :private
    attribute :response,  ActionController::Parameters, writer: :private

    def initialize(store, response, options={})
      self.store = store
      self.params = options
      self.response = response
    end

    def call
      account_movement = store.account_movements.create!(
                                                          confirmation_number: response[:ConfirmationNumber],
                                                          transaction_id: response[:TransactionId],
                                                          merchant_id: response[:MerchantId],
                                                          terminal_id: response[:TerminalId],
                                                          total_amount: response[:TotalAmount].to_i,
                                                          payment_status: response[:PaymentStatus],
                                                          code: response[:Code],
                                                          description_of_transaction: response[:Description],
                                                          description: params[:product_description],
                                                          transaction_time: response[:TxnTime],
                                                          client_email: params[:email],
                                                          street: params[:street],
                                                          zip: params[:zip],
                                                          region: params[:region],
                                                          customer_ip: params[:customer_ip],
                                                          country: params[:country],
                                                          city: params[:city]
                                                        )
      account_movement.save!
      return error(
        title: ERROR_TITLE,
        code: 404,
        message: "Account Movement could not be created"
        ) unless account_movement

      success(account_movement)

     rescue ActiveRecord::RecordInvalid => e
       return error(response: e.record, title: ERROR_TITLE, code: 422,
                    message: 'Account Movement could not be created', errors: e.record.errors)
     rescue => e
       return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
     end
   end
end
