module GatewayServices
  class CreateUser < ::BaseService
      require 'faraday'
      require 'json'

      ERROR_TITLE = 'Merchant Error'.freeze
      SUCCES_MARCHANT = '0'.freeze

      attribute :user
      attribute :merchant_params, Hash, writer: :private

      def initialize(user, options={})
        self.user = user
        self.merchant_params = options
      end

      def call
        @transaction_id= Transaction.create!(transactionable_type: "merchant").transaction_id
        response
      end

      def response
        encrypted_attributes =  ::Requests::EncryptionRequest.new(attributes_to_encrypt).call_to_payment_gateway
        res = RestClient.post( "https://lamda-payments-test.datapaga.com/system.php",
                              {
                                "encodedMessage" => "#{encrypted_attributes[:encodedMessage_req]}",
                                "signature" => "#{encrypted_attributes[:make_signature]}"
                              },
                                "verify_ssl" => true)

        body = CGI::unescape(res.body).gsub("encodedMessage=", "")
        body=  body.slice(0..(body.index('&')))
        body = Base64.decode64(body)
        body = body.force_encoding("ASCII-8BIT").encode('UTF-8', replace: '', :undef => :replace)
        body = JSON.parse(body)

      end

      def url
        "https://lamda-payments-test.datapaga.com/system.php"
      end


      def xml
        result = ::Templates::PG::XML.new(user ,
                                          merchant_params,
                                          @transaction_id).call
      end

      def encodedMessage_req
        @encodedMessage_req= Base64.encode64(xml)
      end

      def attributes_to_encrypt
        {
          xml: xml,
          transaction_id: @transaction_id
        }
      end
    end
end
