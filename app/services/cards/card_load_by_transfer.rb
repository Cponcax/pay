module Cards
  class CardLoadByTransfer

    def initialize(card, options={})
      @client_id = card[:client_id]
      @card_id = card[:card_id]
      @total_amount = options[:amount].to_i
    end

    def call
      @transaction_id= Transaction.create!(transactionable_type: "card_load").transaction_id
      @order_id =  "LCS" + @transaction_id
      response =  ::Requests::GenerateRequest.new(attributes_to_card_load).call
      puts "==============REQUEST"
      puts response

      body ={
            transaction_id: @transaction_id,
            transaction_type: response["CardLoadResponse"]["TransactionType"],
            client_id: response["CardLoadResponse"]["ClientId"],
            order_id:  @order_id,
            card_id: response["CardLoadResponse"]["CardId"],
            amount: response["CardLoadResponse"]["Amount"],
            merchant_debit: response["CardLoadResponse"]["MerchantDebit"],
            response_code: response["CardLoadResponse"]["ResponseCode"],
            response_txt: response["CardLoadResponse"]["ResponseTxt"]
          }
    end

    def url
      "https://lamda-cards-test.datapaga.com/secureCard/post/CardLoad/index.php"
    end

    def xml
    #I'm sorry for this logic but i had no choice :(...
    merchantId = Rails.application.secrets.merchant_id
    terminalId = Rails.application.secrets.terminal_id
    terminal_password_encrypted = Rails.application.secrets.terminal_password_encrypted

    @xml_post_string=
    "<?xml version='1.0' encoding='UTF-8'?>
    <CardLoadRequest>
    <Credentials>
    <MerchantId>#{merchantId}</MerchantId>
    <TerminalId>#{terminalId}</TerminalId>
    <TerminalPassword>#{terminal_password_encrypted}</TerminalPassword>
    </Credentials>
    <TransactionId>#{@transaction_id}</TransactionId>
    <TransactionType>LC010</TransactionType>
    <ClientId>#{@client_id}</ClientId>
    <CardId>#{@card_id}</CardId>
    <OrderId>#{@order_id}</OrderId>
    <Amount>#{@total_amount}</Amount>
    <Currency>978</Currency>
    </CardLoadRequest>"
    end

    def attributes_to_card_load
      {
        url: url,
        xml: xml,
        transaction_id: @transaction_id
      }
    end
  end
end
