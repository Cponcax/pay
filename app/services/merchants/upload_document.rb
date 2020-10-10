module Merchants
  class UploadDocument
    require "base64"
    require 'openssl'

    ERROR_TITLE = 'Doc Error'.freeze
    SUCCES_UPLOAD_DOC = '0'.freeze

    def initialize(attributes)
      @user = attributes[:current_resource_owner]
      @store = attributes[:store]
      @documents_files = attributes[:documents_files]
    end

    def call
      transaction =  Transaction.create!(transactionable_type: "Doc")
      @transaction_id = transaction.transaction_id

      if @store.docs.count <= 4
        @result = response
        body = Base64.decode64(CGI::unescape(@res).gsub("encodedMessage=", ""))
        #remove invalid chart
        xml_request = body.force_encoding("ASCII-8BIT")
                          .encode('UTF-8', replace: '', :undef => :replace)
        #sorting out xml
        response_xml = Nokogiri.XML(xml_request)
        #parse xml to Json
        response_json= Hash.from_xml(response_xml.to_s)
        # puts "===================RESPONSE JSON"
         puts response_json

        if response_json["UploadDocumentsResponse"]["Code"] == SUCCES_UPLOAD_DOC
          return {response:  true}

        end
      end
    end

    def response
      encrypted_attributes = ::Requests::EncryptionRequest.new(attributes_to_encrypt).call_to_payment_gateway_upload_docs
      encodedMessage_req = encrypted_attributes[:encodedMessage_req]
      make_signature = encrypted_attributes[:make_signature]
      response = RestClient.post(
      "https://lamda-payments-test.datapaga.com/acquiring.php",
      {
      "encodedMessage" => "#{encodedMessage_req}",
      "signature" => "#{make_signature}",
      'version' => '1.0',
      'proof_of_home_address' =>  @documents_files[:proof_of_home_address],
      'multipart'=> true
      },'verify_ssl' => false)

      @res = response.body
    end

    private

    def sanitize(value)
      value.original_filename.gsub(".jpg", "").gsub(".png", "").gsub(".pdf", "")
    end

    def xml
      #I'm sorry for this logic but i had no choice :(...
      merchantId = @store.merchant.merchant_id
      terminalId = @store.merchant.terminal_id
      api_password_encrypted = Digest::SHA256.hexdigest @store.merchant.api_password.to_s

    @xml_post_string = "<?xml version='1.0' encoding='UTF-8'?>
    <UploadDocumentsRequest>
    <Credentials>
    <MerchantId>#{merchantId}</MerchantId>
    <TerminalId>#{terminalId}</TerminalId>
    <TerminalPassword>#{api_password_encrypted}</TerminalPassword>
    </Credentials>
    <TransactionId>#{@transaction_id}</TransactionId>
    <TransactionType>LP011</TransactionType>
    </UploadDocumentsRequest>"

    end

    def json_initializing_docs
      {
        proof_of_home_address: @documents_files[:proof_of_home_address],
        bank_details: @documents_files[:bank_details]
      }
    end

    def attributes_to_encrypt
      {
        xml: xml,
        transaction_id: @transaction_id,
        private_key: @store.merchant.private_key,
        api_password:  @store.merchant.api_password
      }
    end
  end
end
