module GatewayServices
  class Charge < Base
    require 'faraday'
    require 'json'

    ERROR_TITLE = 'Charge Error'.freeze
    SUCCES_MARCHANT = '0'.freeze
    TEMPLATE_PATH = ::Templates::PG::ChargeXML

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
      acquiring = self.class.get("/acquiring.php", store, options, TEMPLATE_PATH)
      charge = AccountMovements::Create.new(store, acquiring.response, options).call

      balance = ::Merchants::Balance.new(store, acquiring).call
      unless acquiring.succeed?
        return error(
                      response: acquiring.error_message,
                      title: ERROR_TITLE,
                      code: 422,
                      message: 'Charge could not be created',
                      errors: acquiring.errors
                    )
        else
        success(acquiring.response, charge.response.uuid)
      end
    end
  end
end
