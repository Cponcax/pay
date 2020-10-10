module Api
  module Datapaga
    module Dashboard
      module V1
        class AccountMovementsController < BaseController
          before_action -> { doorkeeper_authorize! :write }, except: [:create]
          before_action :find_merchant, only: [:create]
          before_action :find_store, only: [:index]
          before_action :find_account_movement, only: [:show]

          def index
            unless auth_rsa.nil?
              unless @store.nil?
                @account_movements = @store.account_movements
                render json: @account_movements,  status: :ok
              else
                render json: {message: "Record Not Found", code: "404"}, status: 404
              end
            end
          end

          def show
            unless auth_rsa.nil?
              unless @account_movement.nil?
                render json: @account_movement, serializer: DetailAccountMovementSerializer, status: :ok
              else
                render json: {message: "Record Not Found", code: "404"}, status: 404
              end
            end
          end

          def create
            unless @verified_store.nil?
              @result = ::Merchants::MakeCharges.new(attributes_to_make_charge).call
              if  @result[:code] == "201"
                render json: @result, status: 201
              else
                render json: @result, status: :unprocessable_entity
              end
            else
              render json: {message: "Record not found", error: "404"}, status: 404
            end
          end

          private

          def account_movement_params
            params.require(:account_movement).permit(
                                                    :first_name,
                                                    :last_name,
                                                    :web_site_url,
                                                    :phone,
                                                    :country,
                                                    :city,
                                                    :email,
                                                    :api_key,
                                                    :api_secret,
                                                    :customer_ip,
                                                    :region,
                                                    :zip,
                                                    :street,
                                                    :total_amount,
                                                    :product_description,
                                                    :card_holder_name,
                                                    :card_number,
                                                    :card_expire_month,
                                                    :card_expire_year,
                                                    :card_type,
                                                    :card_security_code,
                                                    :account_movement_id)


          end

          def attributes_to_make_charge
            {
              first_name: account_movement_params[:first_name],
              last_name: account_movement_params[:last_name],
              web_site_url: account_movement_params[:web_site_url],
              phone: account_movement_params[:phone],
              country: account_movement_params[:country],
              city: account_movement_params[:city],
              email: account_movement_params[:email],
              customer_ip: account_movement_params[:customer_ip],
              zip: account_movement_params[:zip],
              street: account_movement_params[:street],
              total_amount: account_movement_params[:total_amount],
              product_description: account_movement_params[:product_description],
              card_holder_name: account_movement_params[:card_holder_name],
              card_number: account_movement_params[:card_number],
              card_expire_month: account_movement_params[:card_expire_month],
              card_expire_year: account_movement_params[:card_expire_year],
              card_type: account_movement_params[:card_type],
              card_security_code: account_movement_params[:card_security_code],
              region: account_movement_params[:region],
              store: @verified_store
            }
          end

          def find_merchant
            @verified_store = ::VerifyRequestIntegrity.new(
                              {api_secret: account_movement_params[:api_secret]}).vefiry
          end

          def find_store
            @store= Store.find_by(uuid: params[:store_uuid])
          end

          def find_account_movement
            @store= Store.find_by(uuid: params[:store_uuid])
            @account_movement = @store.account_movements.find(params[:account_movement_id].to_i)
          end
        end
      end
    end
  end
end
