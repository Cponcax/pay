module LamdaServices
  class Base
    include Virtus.model(strict: true)
    require 'json'

    class << self
      URL_BASE= 'https://lamda-cards-test.datapaga.com'
      SUCCESS = '0'.freeze

      def call(*args)
        if respond_to?(:call)
          new().call(*args)
        else
          raise InvalidServiceError
        end
      end

      def get(path, account_movement, options = {}, template_path)
        @transaction_id= Transaction.create!(transactionable_type: "merchant").transaction_id
        response =  ::Requests::GenerateRequest.new(attributes_to_card_load).call
      end

    private
      def handler response
        if  response.has_value?("Success")
         response = Success.new(response)
        else
          error_message =  Failure.new(response)
        end
      end
    end

    def call(*args)
      raise NotImplementedError
    end

    #
    # == InvalidServiceError
    #
    # The service doesn't have a call method.
    #
    class InvalidServiceError < StandardError; end

    #
    # == NotImplementedError
    #
    # The service hasn't implemented a call method.
    #
    class NotImplementedError < StandardError; end

    protected

      def success(response)
        Success.new(response)
      end

      def error(response)
        Failure.new(response)
      end
  end
end
