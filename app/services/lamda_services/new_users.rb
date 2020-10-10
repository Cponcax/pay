module LamdaServices
  class NewUsers < ::BaseService
    require 'faraday'
    require "base64"
    require 'openssl'

    ERROR_TITLE = 'Store Error'.freeze
    SUCCES_MAKE_MARCHANT = '0'.freeze
    SUCCES_PLASTICAR_CARD = '1001'.freeze


    attribute :user_id,  Integer, writer: :private
    attribute :store_uuid, String, writer: :private

    def initialize(user_id, store_uuid)
      self.store_uuid = store_uuid
      self.user_id = user_id
    end

    def call
      transaction = Transaction.create!(transactionable_type: "Store")
      @transaction_id = transaction.transaction_id
      @order_id =  "LCS" + @transaction_id.to_s
      request = ::Requests::GenerateRequest.new(attributes_to_request).call

      store = ::Stores::FindStoreByUuid.new(store_uuid).call

       success request

      rescue ActiveRecord::RecordInvalid => e
       return error(response: e.record, title: ERROR_TITLE, code: 422,
                    message: 'Card could not be created', errors: e.record.errors)
      rescue => e
       return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
    end

    private

    def url
       "https://lamda-cards-test.datapaga.com/secureCard/post/PlasticCardRequest/index.php"
    end

    def xml
      store = ::Stores::FindStoreByUuid.new(store_uuid).call
      user = ::Users::FindUser.new(user_id).call

      result = ::Templates::Lamda::XmlNewUsers.new(@transaction_id,
                                                  user,
                                                  @order_id,
                                                  store).call
    end


    def attributes_to_request
      {
        url: url,
        xml: xml,
        transaction_id: @transaction_id
      }
    end

    def find_user id
      User.find(id)
    end

    def find_store store_uuid
      Store.find_by(uuid: store_uuid)
    end
  end
end
