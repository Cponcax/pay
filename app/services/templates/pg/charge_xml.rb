module Templates
  module PG
    class ChargeXML < ::BaseService

      attribute :store, ActionController::Parameters, writer: :private
      attribute :options, Hash, write: :private
      attribute :merchant,  ActionController::Parameters, write: :private
      attribute :transaction_id, String, write: :private

      def initialize(obj, options, transaction_id)
        self.store = obj
        self.options = options
        self.transaction_id = transaction_id
        self.merchant = store.merchant
      end


    def call
      #I'm sorry for this logic but i had no choice :(...
    api_password_encrypt = Digest::SHA256.hexdigest merchant.api_password
    @xml_post_string =
    "<?xml version='1.0' encoding='UTF-8' ?>
    <TransactionRequest xmlns='https://lamda-payments-test.datapaga.com/acquiring.php'>
      <ResponseFormat>json</ResponseFormat>
      <Language>ENG</Language>
      <Credentials>
        <MerchantId>#{merchant.merchant_id}</MerchantId>
        <TerminalId>#{merchant.terminal_id}</TerminalId>
        <TerminalPassword>#{api_password_encrypt}</TerminalPassword>
      </Credentials>
      <TransactionType>LP001</TransactionType>
      <TransactionId>#{transaction_id}</TransactionId>
      <ReturnUrl page='#{options[:web_site_url]}'>
      <Param>
        <Key>inv</Key>
        <Value>#{transaction_id}</Value>
      </Param>
      </ReturnUrl>
      <CurrencyCode>EUR</CurrencyCode>
      <TotalAmount>#{options[:total_amount]}</TotalAmount>
      <ProductDescription>#{options[:product_description]}</ProductDescription>
      <CustomerDetails>
        <FirstName>#{options[:first_name]}</FirstName>
        <LastName>#{options[:last_name]}</LastName>
        <CustomerIP>#{options[:customer_ip]}</CustomerIP>
        <Phone>#{options[:phone]}</Phone>
        <Email>#{options[:email]}</Email>
        <Street>#{options[:street]}</Street>
        <City>#{options[:city]}</City>
        <Region>#{options[:region]}</Region>
        <Country>#{options[:country]}</Country>
        <Zip>#{options[:zip]}</Zip>
      </CustomerDetails>
      <CardDetails>
        <CardHolderName>#{options[:card_holder_name]}</CardHolderName>
        <CardNumber>#{options[:card_number]}</CardNumber>
        <CardExpireMonth>#{options[:card_expire_month]}</CardExpireMonth>
        <CardExpireYear>#{options[:card_expire_year]}</CardExpireYear>
        <CardType>#{options[:card_type]}</CardType>
        <CardSecurityCode>#{options[:card_security_code]}</CardSecurityCode>
      </CardDetails>
    </TransactionRequest>"
      end
    end
  end
end
