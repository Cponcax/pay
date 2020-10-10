module Public
  module GatewayServices
    class Charge < Base
      require 'faraday'
      require 'json'

      ERROR_TITLE = 'Charge Error'.freeze
      SUCCES_MARCHANT = '0'.freeze
      TEMPLATE_PATH = ::Templates::PG::ChargeXML
      ERROR_TITLE = "Action could not be completed"

      attribute :store, ActionController::Parameters, writer: :private
      attribute :options, Hash, writer: :private
      attribute :charge, ActionController::Parameters, writer: :private

      def initialize(obj, options={})
        self.store = obj
        self.options = options
        self.options[:type_request] = "charge".freeze
        self.charge = options
      end

      def call
        response = self.class.get("/acquiring.php", store, options, TEMPLATE_PATH)
        charge = AccountMovements::Create.new(store, response.response, options).call

        if  response.succeed?
          balance = Merchants::Balance.new(store, options[:type_request], response).call
        end
        unless response.succeed?
          return error(
                        message: response.errors,
                        code: response.error_code
                      )
          else
          success(response.response, charge.response.uuid)
        end
      end
    end
  end
end
