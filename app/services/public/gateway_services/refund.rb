module Public
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

        if response.succeed?
          balance = Merchants::Balance.new(account_movement.store, options[:type_request], response).call
          account_movement.update(refund: true,  total_amount: -account_movement[:total_amount]) if balance.succeed?
        end

        unless response.succeed?
          return error(
                        message: response.errors,
                        code: response.error_code
                      )
          else
            success(response.response, account_movement[:uuid] )
        end
      end
    end
  end
end
