module Templates
  module PG
    class XML < ::BaseService

      attribute :user, ActionController::Parameters, writer: :private
      attribute :merchant_params, Hash, write: :private
      attribute :transaction_id, String, write: :private

      def initialize(user, merchant_params, transaction_id)
        self.user = user
        self.merchant_params = merchant_params
        self.transaction_id = transaction_id
      end


      def call
        #I'm sorry for this logic but i had no choice :(...
        api_password_encrypt =  Rails.application.secrets.api_password_encrypted
        @xml_post_string =
        "<?xml version='1.0' encoding='UTF-8' ?>
        <CreateMerchant xmlns='https://lamda-payments-test.datapaga.com/system.php'>
        <ResponseFormat>json</ResponseFormat>
        <Credentials>
        <Password>#{api_password_encrypt}</Password>
        </Credentials>
        <RequestType>SA001</RequestType>
        <RequestId>#{transaction_id}</RequestId>
        <MerchantDetails>
        <CorporateName>#{merchant_params[:name]}</CorporateName>
        <FirstName>#{user.first_name}</FirstName>
        <LastName>#{user.last_name}</LastName>
        <WebSiteUrl>http://#{merchant_params[:web_site_url]}</WebSiteUrl>
        <Phone>#{merchant_params[:phone]}</Phone>
        <Country>#{merchant_params[:country]}</Country>
        <City>#{merchant_params[:city]}</City>
        <CurrencyCode>EUR</CurrencyCode>
        <Email>#{merchant_params[:email]}</Email>
        <Gateway>TESTGATEWAY</Gateway>
        </MerchantDetails>
        </CreateMerchant>"
      end
    end
  end
end
