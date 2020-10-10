module Api
  module Datapaga
    module Dashboard
      module V1
        class MerchantsController < BaseController
          before_action -> { doorkeeper_authorize! :write }, except: [:create]
          before_action :find_store, only: [:balance]


          def balance
            unless auth_rsa.nil?
              unless @store.nil?
                @balance = ::Merchants::FindMerchant.new(@store).call
                render json: @balance, serializer: MerchantSerializer, status: :ok
              else
                render json: {message: "Record Not Found", code: "404"}, status: 404
              end
            end
          end

          private

          def amechant_params
            params.require(:account_movement).permit()
          end


          def find_store
            @store= Store.find_by!(uuid: params[:store_uuid])
          end
        end
      end
    end
  end
end
