module Cards
  class CardBalance
    require 'faraday'
    require 'openssl'
    require "base64"

    RESPONSE_CODE = "2001".freeze

    def initialize(attributes)
      @user = attributes[:user]
      @store = attributes[:store]
      @card = attributes[:card]
    end

    def call
      response_json = ::Requests::GenerateRequest.new(attributes_to_request).call
      additional_amount2 = response_json["CardInfoResponse"]["CardInfoLCS"]["xsAdditionalAmount2"]

      if response_json["CardInfoResponse"]["ResponseCode"] == RESPONSE_CODE
        total_amount_card= Money.new(additional_amount2.to_s, "USD")
        total_amount_card.format
        @card.update_attributes(balance: additional_amount2)
      end
    end

    private

    def range_dates
      current_day = Time.zone.today
      @start_date = current_day.to_s.gsub("20", "1").gsub("-","")
      @end_date =  (current_day -7).to_s.gsub("20", "1").gsub("-","")
    end


    def url
      "https://lamda-cards-test.datapaga.com/secureCard/post/CardInfo/index.php"
    end

    def xml
    #I'm sorry for this logic but i had no choice :(...
    merchantId = Rails.application.secrets.merchant_id
    terminalId = Rails.application.secrets.terminal_id
    terminal_password_encrypted = Rails.application.secrets.terminal_password_encrypted
    generate_transaction_id
    range_dates
    @xml_post_string=
    "<?xml version='1.0' encoding='UTF-8'?>
    <CardInfoRequest>
    <Credentials>
    <MerchantId>#{merchantId}</MerchantId>
    <TerminalId>#{terminalId}</TerminalId>
    <TerminalPassword>#{terminal_password_encrypted}</TerminalPassword>
    </Credentials>
    <TransactionId>#{@transaction_id}</TransactionId>
    <TransactionType>LC002</TransactionType>
    <ClientId>#{@store.client_id}</ClientId>
    <CardId>#{@card.card_id}</CardId>
    <ExpDate>#{@card.expiration_date}</ExpDate>
    <MaxRows>20</MaxRows>
    <StartDate>#{@start_date}</StartDate>
    <EndDate>#{@end_date}</EndDate>
    </CardInfoRequest>"
    end

    def attributes_to_request
      {
        url: url,
        xml: xml,
        transaction_id: @transaction_id
      }
    end

    def generate_transaction_id
      @transaction_id= Transaction.create!(
                                          transactionable_type: "card_info",
                                          transactionable_id: @store.id).transaction_id
    end
  end
end
