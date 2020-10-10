module Merchants
  class NewMerchant < ::BaseService
    ERROR_TITLE = 'Merchant Error'.freeze
    SUCCES_MAKE_MARCHANT = '0'.freeze

    attribute :store, Object, writer: :private
    attribute :user, Object, writer: :private
    attribute :merchant_params, Hash, writer: :private
    attribute :new_store, ActionController::Parameters, writer: :private

    def initialize(store, new_store, user, options={})
      self.store = store
      self.new_store = new_store
      self.user = user
      self.merchant_params = options
    end

    def call
      ActiveRecord::Base.transaction do
        merchant_user = ::GatewayServices::CreateUser.new(user, merchant_params).call
        
        request_code = merchant_attributes["Code"] unless merchant_attributes.nil?
        merchant =  new_store.build_merchant(
                                              name: store.name,
                                              first_name: user.first_name,
                                              last_name: user.last_name,
                                              web_site_url: store.web_site_url,
                                              phone: store.phone,
                                              country: store.country,
                                              city: store.city,
                                              email: merchant_params[:email]
                                            )

        if request_code == SUCCES_MAKE_MARCHANT
          merchant.save!
          merchant.update!(
                            merchant_id: merchant_attributes["MerchantDetails"]["MerchantID"],
                            terminal_id: merchant_attributes["MerchantDetails"]["TerminalID"],
                            private_key: merchant_attributes["MerchantDetails"]["PrivateKey"],
                            api_password: merchant_attributes["MerchantDetails"]["ApiPassword"],
                            currency: merchant_attributes["MerchantDetails"]["Currency"]
                          )

          return error(
                        title: ERROR_TITLE,
                        code: 404,
                        message: 'card not be created'
                        ) unless merchant

          success(merchant)
        else
          return error(
                        title: ERROR_TITLE,
                        code: 404,
                        message: 'Merchant not be created'
                      )
        end
      end

      rescue ActiveRecord::RecordInvalid => e
        return error(
                      response: e.record,
                      title: ERROR_TITLE,
                      code: 422,
                      message: 'Merchant could not be created',
                      errors: e.record.errors
                    )
      rescue => e
        return error(
                      response: e,
                      title: ERROR_TITLE,
                      message: e.message,
                      code: 422
                    )
    end
  end
end
