module Api
  module Datapaga
    module Public
      module V1
        module Stores
          class StoresController < BaseController
            before_action :find_store, only: [:balance, :card_transfer]

            def balance
              unless @store.nil?
                @balance = ::Public::Merchants::FindMerchant.new(@store).call
                render json:  {response: Api::Public::Stores::BalanceSerializer.new(@balance)}, status: :ok
              else
                render json: {
                              error: {
                                      message: "Record Not Found",
                                      code: "0001"
                                      }
                                      }, status: 404
              end
            end

            def card_transfer
              unless @store.nil?
                @result = ::Cards::Transfer.new(@store, card_transfer_params).call
                if @result.succeed?
                  render json: @result, status: :created
                else
                  render json: @result, status: :unprocessable_entity
                end
              else
                render json: {
                              response: {
                                          status: "Error",
                                          message: "Record Not Found", code: "404"}}, status: 404
              end
            end

            private

            def store_params
              params.require(:store).permit(:api_key, :api_secret, :start_date, :end_date, :uuid)
            end

            def card_transfer_params
              params.require(:store).permit(:api_key, :api_secret, :amount, :card_code)
            end

            def find_store
              @store = Store.find_by(api_secret_encoded: store_params[:api_secret])
            end
          end
        end
      end
    end
  end
end
