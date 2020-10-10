module Templates
  module Lamda
    class XML < ::BaseService

      attribute :user, ActionController::Parameters, writer: :private
      attribute :card_attributes, ActionController::Parameters, write: :private
      attribute :order_id, String, write: :private
      attribute :transaction_id, String, write: :private

      def initialize(transaction_id, card_attributes, order_id, user)
        self.transaction_id = transaction_id
        self.card_attributes = card_attributes
        self.order_id = order_id
        self.user = user
      end


      def call
        #I'm sorry for this logic but i had no choice :(...
        merchantId = Rails.application.secrets.merchant_id
        terminalId = Rails.application.secrets.terminal_id
        terminal_password_encrypted = Rails.application.secrets.terminal_password_encrypted

        @xml_post_string=
        "<?xml version='1.0' encoding='UTF-8'?>
        <PlasticCardRequestRequest>
        <Credentials>
        <MerchantId>#{merchantId}</MerchantId>
        <TerminalId>#{terminalId}</TerminalId>
        <TerminalPassword>#{terminal_password_encrypted}</TerminalPassword>
        </Credentials>
        <TransactionId>#{transaction_id}</TransactionId>
        <TransactionType>LC101</TransactionType>
        <ProductType>LP006</ProductType>
        <IdentificationType>#{user.identification_type}</IdentificationType>
        <IdentificationValue>#{user.identification_value}</IdentificationValue>
        <Email>#{user.email}</Email>
        <Title>#{user.title}</Title>
        <FirstName>#{user.first_name}</FirstName>
        <LastName>#{user.last_name}</LastName>
        <DOB>#{user.birthday}</DOB>
        <Address1>#{card_attributes.address_one}</Address1>
        <Address2>#{card_attributes.address_two}</Address2>
        <PostalCode>#{card_attributes.postalcode}</PostalCode>
        <City>#{card_attributes.city}</City>
        <State>#{card_attributes.state}</State>
        <Country>#{card_attributes.country}</Country>
        <Nationality>#{user.nationality}</Nationality>
        <PhoneCountryCode>#{card_attributes.phone_country_code}</PhoneCountryCode>
        <Phone>#{card_attributes.phone}</Phone>
        <OrderId>#{order_id}</OrderId>
        </PlasticCardRequestRequest>"
      end
    end
  end
end
