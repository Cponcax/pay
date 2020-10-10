module Cards
  class SendDocs
    require "base64"
    require 'openssl'

    ERROR_TITLE = 'Doc Error'.freeze
    SUCCES_UPLOAD_DOC = '1001'.freeze

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
        xml_request = body.force_encoding("ASCII-8BIT").encode('UTF-8', replace: '', :undef => :replace)
        #sorting out xml
        response_xml = Nokogiri.XML(xml_request)
        #parse xml to Json
        response_json= Hash.from_xml(response_xml.to_s)
        # puts "===================RESPONSE JSON"
         puts response_json
        if response_json["UploadDocumentsResponse"]["ResponseCode"] == SUCCES_UPLOAD_DOC
          return {response: true}
        end
      end
    end

    def response
      response = RestClient.post(
      "https://lamda-cards-test.datapaga.com/secureCard/post/UploadDocuments/index.php",
      {
      "encodedMessage" => "#{encodedMessage_req}",
      "signature" => "#{make_signature}",
      'citizen_id[]' =>  @documents_files[:citizen_id],
      'p_address' =>  @documents_files[:p_address],
      'multipart' => true
      })

      @res = response.body
    end

    private

    def sanitize(value)
      value.original_filename.gsub(".jpg", "").gsub(".png", "").gsub(".pdf", "")
    end

    def request_body
      #generate body request to send  require 'net/http/post/multipart'
      encodedMessage_req = CGI::escape(@encodedMessage_req)
      signature = CGI::escape(@signature)
      @postdata= "encodedMessage=" + encodedMessage_req + "&signature="+ signature
    end

    def encodedMessage_req
      @encodedMessage_req= Base64.encode64(xml)
    end

    def url
      "https://lamda-cards-test.datapaga.com/secureCard/post/UploadDocuments/index.php"
    end

    def xml
      #I'm sorry for this logic but i had no choice :(...
      merchantId = Rails.application.secrets.merchant_id
      terminalId = Rails.application.secrets.terminal_id
      terminal_password_encrypted = Rails.application.secrets.terminal_password_encrypted
    @xml_post_string=
    "<?xml version='1.0' encoding='UTF-8'?>
    <UploaDocumentsRequest>
    <Credentials>
    <MerchantId>#{merchantId}</MerchantId>
    <TerminalId>#{terminalId}</TerminalId>
    <TerminalPassword>#{terminal_password_encrypted}</TerminalPassword>
    </Credentials>
    <TransactionId>#{@transaction_id}</TransactionId>
    <TransactionType>LC026</TransactionType>
    <ClientId>#{@store.client_id}</ClientId>
    <KYCLevel>4</KYCLevel>
    </UploaDocumentsRequest>"
    end

    def encrypt_terminal_password
     @terminal_password= Digest::SHA256.hexdigest Rails.application.secrets.terminal_password
    end

    def make_signature
      terminal_password = Rails.application.secrets.terminal_password
      @signature_key = terminal_password.to_s + @transaction_id.to_s
      @signature=   Base64.encode64(OpenSSL::HMAC.digest('sha256', @signature_key, xml)).gsub("\n", "")
    end

    def json_initializing_docs
      {
        citizen_id: @documents_files[:citizen_id],
        p_address: @documents_files[:p_address]

      }
    end

    def attributes_to_encrypt
      {
        xml: xml,
        transaction_id: @transaction_id
      }
    end
  end
end
