module GatewayServices
  class Refund < Base
    require 'faraday'
    require 'json'

    ERROR_TITLE = 'Refund Error'.freeze
    SUCCES_MARCHANT = '0'.freeze
    TEMPLATE_PATH = ::Templates::PG::RefundXML

    attribute :account_movement, ActionController::Parameters, writer: :private
    attribute :options, Hash, writer: :private

    def initialize(account_movement, options={})
      self.account_movement = account_movement
      self.options = options
      self.options[:type_request] = "refund".freeze
    end

    def call
      response = self.class.get("/acquiring.php", account_movement, options, TEMPLATE_PATH)
      unless response.succeed?
        return error(
                      response: response.error_message,
                      title: ERROR_TITLE,
                      code: 422,
                      message: 'Refund could not be created',
                      errors: response.errors
                    )
        else
        success response
      end
    end
  end
end
