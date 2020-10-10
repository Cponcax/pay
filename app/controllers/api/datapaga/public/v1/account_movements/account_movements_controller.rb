module Api
  module Datapaga
    module Public
      module V1
        module AccountMovements
          class AccountMovementsController < BaseController
            require 'date'
            before_action :find_account_movement_to_refund, only: [:refund]
            before_action :find_account_movement_to_detail, only: [:show]
            before_action :find_store, only: [:charge]

            def index
              @account_movements= ::Public::Filters::FindStoresForDate.new(store_attributes).find_store
              paginate = ::Paginations::Paginate.new(account_movement_params[:page],
                                                  @account_movements[:account_movements])
              if  @account_movements[:success] and paginate.succeed?
                render json: paginate.response,status: :ok
              elsif @account_movements[:invalid]
                render json: {message: @account_movements[:message]}, status: :unprocessable_entity
              else
                render json: {
                              error: {
                                      message: "Record Not Found",
                                       code: "0001"
                                       }
                                      }, status: 404
              end
            end

            def charge
              unless @store.nil?
                @result = ::Public::GatewayServices::Charge.new(@store, attributes_to_make_charge).call
                if @result.succeed?
                  render json: {
                                response:
                                        {
                                        status: "APPROVED",
                                        code: "201",
                                        uuid: @result.obj
                                      }
                                }, status: :created
                else
                  render json: {
                                error: @result.response
                                } , status: :unprocessable_entity
                end
              end
            end

            def show
              if  !@store.nil? and !@account_movement.nil?
                result = DetailAccountMovementSerializer.new(@account_movement)
                render json: {response: result.object}, status: :ok
              else
                render json: {
                              error: {
                                      message: "Record Not Found",
                                      code: "0001"
                                      }}, status: 404
              end
            end

            def refund
              unless @account_movement.nil?
                @result = ::Public::GatewayServices::Refund.new(@account_movement, refund_params).call
                if @result.succeed?
                  render json: {
                                response:
                                        {
                                        status: "APPROVED",
                                        code: "201",
                                        uuid: @result.obj
                                      }
                                }, status: :created
                else
                  render json: {
                                error: @result.response
                                } , status: :unprocessable_entity
                end
              else
                render json: {
                              error: {
                                      message: "Record Not Found",
                                      code: "0001"
                                      }}, status: 404

              end
            end

            private


            def account_movement_params
              params.require(:account_movement).permit(
                                                        :api_key,
                                                        :api_secret,
                                                        :start_date,
                                                        :end_date,
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
                                                        :account_movement_id,
                                                        :page
                                                      )

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
                region: account_movement_params[:region]
              }
            end

            def refund_params
              params.require(:refund).permit(
                                              :api_key,
                                              :api_secret,
                                              :confirmation_number,
                                              :refund_description,
                                              :ip_customer,
                                              :uuid
                                            )

            end

            def store_attributes
              {
                api_key: params[:account_movement][:api_key],
                api_secret: params[:account_movement][:api_secret],
                start_date: params[:account_movement][:start_date],
                end_date: params[:account_movement][:end_date]
              }
            end

            def find_store
              @store = ::VerifyRequestIntegrity.new(
                                {api_secret: account_movement_params[:api_secret]}).vefiry
            end

            def find_account_movement_approved
              account_movements = AccountMovement.account_movement_approved
              @account_movement= account_movements.find_by!(uuid: params[:uuid])
            end

            def find_account_movement_to_refund
              @store= Store.find_by(api_secret_encoded: params[:refund][:api_secret])
              if !@store.nil?
                @account_movement= @store.account_movements.account_movement_approved.find_by(uuid: refund_params[:uuid])
              end
            end

            def find_account_movement_to_detail
              @store= Store.find_by(api_secret_encoded: params[:account_movement][:api_secret])
              if !@store.nil?
                @account_movement= @store.account_movements.find_by(uuid:  params[:uuid])
              end
            end

          end
        end
      end
    end
  end
end
