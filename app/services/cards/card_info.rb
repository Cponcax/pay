module Cards
  class CardInfo
    require 'faraday'
    require 'openssl'
    require "base64"

    SUCCES_CARD_INFO = '1001'.freeze
    SUCCES_CARD_LIST = '1001'.freeze

    def initialize(attributes)
      @user = attributes[:user]
      @card = attributes[:card]
      @store = attributes[:store]
      @start_date = attributes[:start_date]
      @end_date = attributes[:end_date]
    end

    def call
      response_json =  ::Requests::GenerateRequest.new(attributes_to_request).call

      if response_json["AccountCardListResponse"]["ResponseCode"] == SUCCES_CARD_LIST
        card_attributes = {
          emboss_name: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["EmbossName"],
          card_number: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["CardNumber"],
          order_status: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["OrderStatus"],
          expiration_date: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["ExpirationDate"],
          type_card: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["Type"].downcase,
          product: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["Product"],
          issued_time: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["IssuedTime"],
          issued_date: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["IssuedDate"],
          issued_by: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["IssuedBy"],
          ammount_limit: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["AmountLimit"],
          status: response_json["AccountCardListResponse"]["CardList"]["Card"][0]["Status"]}
          @card.update_attributes(card_attributes)
          @response = @card
      else
        nil
      end
    end

    def histories
      response_json =  ::Requests::GenerateRequest.new(attributes_histories).call

      if response_json["CardInfoResponse"]["ResponseCode"] == SUCCES_CARD_INFO
        response_json = {
            card_info_lcs: response_json["CardInfoResponse"]["CardInfoLCS"],
            transaction_range_summary: response_json["CardInfoResponse"]["TranRangeSummary"]
        }
      else
        nil
      end
    end

    private

    def url
      "https://lamda-cards-test.datapaga.com/secureCard/post/AccountCardList/index.php"
    end

    def xml
    #I'm sorry for this logic but i had no choice :(...
    merchantId = Rails.application.secrets.merchant_id
    terminalId = Rails.application.secrets.terminal_id
    terminal_password_encrypted = Rails.application.secrets.terminal_password_encrypted
    generate_transaction_id
    @xml_post_string=
    "<?xml version='1.0' encoding='UTF-8'?>
    <CardInfoRequest>
    <Credentials>
    <MerchantId>#{merchantId}</MerchantId>
    <TerminalId>#{terminalId}</TerminalId>
    <TerminalPassword>#{terminal_password_encrypted}</TerminalPassword>
    </Credentials>
    <TransactionId>#{@transaction_id}</TransactionId>
    <TransactionType>LC009</TransactionType>
    <ClientId>#{@store.client_id}</ClientId>
    </CardInfoRequest>"
    end

    def xml_histories
      merchantId = Rails.application.secrets.merchant_id
      terminalId = Rails.application.secrets.terminal_id
      terminal_password_encrypted = Rails.application.secrets.terminal_password_encrypted
      generate_transaction_id
      post_string=
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
      <MaxRows>2</MaxRows>
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

    def attributes_histories
      {
        url: "https://lamda-cards-test.datapaga.com/secureCard/post/CardInfo/index.php",
        xml: xml_histories,
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
