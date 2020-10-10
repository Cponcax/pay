module LamdaServices
  class CreateUser < ::BaseService
    require 'faraday'
    require "base64"
    require 'openssl'

    ERROR_TITLE = 'Store Error'.freeze

    attribute :card_attributes,  ActionController::Parameters, writer: :private
    attribute :user, ActionController::Parameters, writer: :private

    def initialize(user, store)
      self.card_attributes = store
      self.user = user
    end

    def call
      transaction = Transaction.create!(transactionable_type: "Store")
      @transaction_id = transaction.transaction_id
      @order_id =  "LCS" + @transaction_id.to_s
      response = ::Requests::GenerateRequest.new(attributes_to_request).call
    end

    private

    def url
       "https://lamda-cards-test.datapaga.com/secureCard/post/PlasticCardRequest/index.php"
    end

    def xml
     result = ::Templates::Lamda::XML.new(@transaction_id,
                                          card_attributes,
                                          @order_id,
                                          user).call
    end

    def attributes_to_request
      {
        url: url,
        xml: xml,
        transaction_id: @transaction_id
      }
    end
  end
end
