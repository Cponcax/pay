module Merchants
  class MakeCharges
    require 'json'

    ERROR_TITLE = 'Error account movements'.freeze
    SUCCES_VERIFY_TRANSACTION = '00'.freeze
    SUCCES_CARD_LOAD = '2001'.freeze

    def initialize(attributes)
      @first_name= attributes[:first_name]
      @last_name= attributes[:last_name]
      @web_site_url= attributes[:web_site_url]
      @phone= attributes[:phone]
      @country= attributes[:country]
      @city= attributes[:city]
      @email= attributes[:email]
      @customer_ip= attributes[:customer_ip]
      @zip= attributes[:zip]
      @street= attributes[:street]
      @total_amount= attributes[:total_amount]
      @product_description= attributes[:product_description]
      @card_holder_name= attributes[:card_holder_name]
      @card_number= attributes[:card_number]
      @card_expire_month= attributes[:card_expire_month]
      @card_expire_year= attributes[:card_expire_year]
      @card_type= attributes[:card_type]
      @card_security_code= attributes[:card_security_code]
      @store = attributes[:store]
      @region = attributes[:region]
    end

    def call
      @transaction_id= Transaction.create!(transactionable_type: "account_movement").transaction_id
      response
      doc = Nokogiri::HTML(@res)
      body = doc.at_css("input").attributes["value"].value
      body = Base64.decode64(body)
      response= JSON.parse(body)

      unless @store.nil?
         @store.account_movements.create!(
                                          confirmation_number: response["ConfirmationNumber"],
                                          transaction_id: response["TransactionId"],
                                          merchant_id: response["MerchantId"],
                                          terminal_id: response["TerminalId"],
                                          total_amount: response["TotalAmount"],
                                          payment_status: response["PaymentStatus"],
                                          code: response["Code"],
                                          description_of_transaction: response["Description"],
                                          description: @product_description,
                                          transaction_time: response["TxnTime"],
                                          client_email: @email,
                                          street: @street,
                                          zip: @zip,
                                          region: @region,
                                          customer_ip: @customer_ip,
                                          country: @country,
                                          city: @city)


      end
      if response["Code"] == SUCCES_VERIFY_TRANSACTION
        generate_order_id
        card_load = ::RequestsToLamda::CardLoad.new(
          client_id: @store.client_id,
          order_id: @order_id,
          card_id: @store.cards.last.card_id,
          total_amount: response["TotalAmount"]
        ).call

        # if card_load["CardLoadResponse"]["ResponseCode"] == SUCCES_CARD_LOAD
        #   ::Merchants::UpdateBalance.new(@store, response["TotalAmount"]).call
        #   response = {
        #     message: "Successful account transaction",
        #     code: "201"
        #   }
        # else
        #   raise
        # end
      else
       raise
      end

      rescue StandardError => e
      return error = {response: "Unprocessable Entity",
                      title: ERROR_TITLE,
                      message: "Account transaction failed",
                      code: 422}

    end

    def response
      response = RestClient.post(
      "https://lamda-payments-test.datapaga.com/acquiring.php",
      {
      "encodedMessage" => "#{encodedMessage_req}",
      "signature" => "#{make_signature}"

    },
      "verify_ssl" => true)
      @res = response.body
    end


    def url
      "https://lamda-payments-test.datapaga.com/acquiring.php"
    end

    def request_body
      encodedMessage_req = CGI::escape(encodedMessage_req= Base64.encode64(xml))
      signature = CGI::escape(make_signature)
      @postdata= "encodedMessage=" + encodedMessage_req + "&signature="+ signature
    end


  def xml
    #I'm sorry for this logic but i had no choice :(...
    api_password_encrypt = Digest::SHA256.hexdigest @store.merchant.api_password
    @xmlReq =
    "<?xml version='1.0' encoding='UTF-8' ?>
    <TransactionRequest>
      <ResponseFormat>json</ResponseFormat>
      <Language>ENG</Language>
      <Credentials>
        <MerchantId>#{@store.merchant.merchant_id}</MerchantId>
        <TerminalId>#{@store.merchant.terminal_id}</TerminalId>
        <TerminalPassword>#{api_password_encrypt}</TerminalPassword>
      </Credentials>
      <TransactionType>LP001</TransactionType>
      <TransactionId>#{@transaction_id}</TransactionId>
      <ReturnUrl page='#{@web_site_url}'>
      <Param>
        <Key>inv</Key>
        <Value>#{@transaction_id}</Value>
      </Param>
      </ReturnUrl>
      <CurrencyCode>EUR</CurrencyCode>
      <TotalAmount>#{@total_amount}</TotalAmount>
      <ProductDescription>#{@product_description}</ProductDescription>
      <CustomerDetails>
        <FirstName>#{@first_name}</FirstName>
        <LastName>#{@last_name}</LastName>
        <CustomerIP>#{@customer_ip}</CustomerIP>
        <Phone>#{@phone}</Phone>
        <Email>#{@email}</Email>
        <Street>#{@street}</Street>
        <City>#{@city}</City>
        <Region>#{@region}</Region>
        <Country>#{@country}</Country>
        <Zip>#{@zip}</Zip>
      </CustomerDetails>
      <CardDetails>
        <CardHolderName>#{@card_holder_name}</CardHolderName>
        <CardNumber>#{@card_number}</CardNumber>
        <CardExpireMonth>#{@card_expire_month}</CardExpireMonth>
        <CardExpireYear>#{@card_expire_year}</CardExpireYear>
        <CardType>#{@card_type}</CardType>
        <CardSecurityCode>#{@card_security_code}</CardSecurityCode>
      </CardDetails>
    </TransactionRequest>"
  end

  private

    def generate_order_id
      @order_id =  "LCS" + @transaction_id
    end

    def encodedMessage_req
      @encodedMessage_req= Base64.encode64(xml)
    end

    def make_signature
      @signature_key = @store.merchant.private_key.to_s +  @store.merchant.api_password.to_s + @transaction_id
      @signature_key = @signature_key.strip
      @signature=   Base64.encode64(OpenSSL::HMAC.digest('sha256', @signature_key, xml))
    end

  end
end
