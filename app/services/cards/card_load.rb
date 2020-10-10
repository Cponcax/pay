module Cards
  class CardLoad

    def initialize(attributes)
      @client_id = attributes[:client_id]
      @order_id = attributes[:order_id]
      @card_id = attributes[:card_id]
      @total_amount = attributes[:total_amount]
    end

    def call
      @transaction_id= Transaction.create!(transactionable_type: "card_load").transaction_id
      response_card_load =  ::Requests::GenerateRequest.new(attributes_to_card_load).call
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
