module Templates
  module PG
    class RefundXML < ::BaseService

      attribute :account_movement, ActionController::Parameters, writer: :private
      attribute :options, Hash, write: :private
      attribute :merchant,  ActionController::Parameters, write: :private
      attribute :transaction_id, String, write: :private

      def initialize(account_movement, options, transaction_id)
        self.account_movement = account_movement
        self.options = options
        self.transaction_id = transaction_id
        self.merchant = account_movement.store.merchant
      end


      def call
        #I'm sorry for this logic but i had no choice :(...
        #https://fedros-dev.gateway-services.com/acquiring.php
    api_password_encrypt =  Digest::SHA256.hexdigest  merchant.api_password
    @xml_post_string =
    "<?xml version='1.0' encoding='UTF-8' ?>
    <RefundRequest xmlns='https://lamda-payments-test.datapaga.com/acquiring.php'>
    <ResponseFormat>json</ResponseFormat>
      <Credentials>
        <MerchantId>#{merchant.merchant_id}</MerchantId>
        <TerminalId>#{merchant.terminal_id}</TerminalId>
        <TerminalPassword>#{api_password_encrypt}</TerminalPassword>
      </Credentials>
      <TransactionType>LP005</TransactionType>
      <TransactionId>#{transaction_id}</TransactionId>
      <ConfirmationNumber>#{account_movement.confirmation_number}</ConfirmationNumber>
      <RefundDescription>#{options['refund_description']}</RefundDescription>
      <CurrencyCode>EUR</CurrencyCode>
      <TotalAmount>#{account_movement.total_amount}</TotalAmount>
      <CustomerIp>#{options['ip_customer']}</CustomerIp>
    </RefundRequest>"
      end
    end
  end
end
