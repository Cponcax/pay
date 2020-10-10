module Api
  module Datapaga
    module Dashboard
      module V1
        class FiltersController < BaseController
          before_action -> { doorkeeper_authorize! :write }
          before_action :find_store, only: [:filter_account_movements, :filters_clients, :filters_home]

          def filter_account_movements
            unless auth_rsa.nil?
              unless @store.nil?
                @response = ::Filters::FindAccountMovements.new(attributes_to_find).call
                unless params[:page].nil?
                  @account_movements = @response.page(params[:page].to_i).per(5)
                else
                  @account_movements = @response
                end
                @total_count = @response.count
                account_movements = @account_movements
                account_movements = ActiveModelSerializers::SerializableResource.new(account_movements,
                                                                                    each_serializer: AccountMovementSerializer).as_json

                render json: {account_movements: account_movements, total_count: @total_count},  status: :ok
              end
            end
          end

          def filters_clients
            unless auth_rsa.nil?
              unless @store.nil?
                @response = ::Filters::FindClient.new(attributes_to_find_client).call
                render json:{number_of_client: @response}, status: :ok
              end
            end
          end

        private

          def filters_params
            params.permit(:date_type, :start_date, :end_date , :amount_type, :total_amount, :status,
                          :store_uuid, :week)
          end

          def attributes_to_chart
            {
              current_day: Time.zone.today,
              store:  @store,
              week: filters_params[:week].to_i,
              user: current_resource_owner
            }
          end

          def attributes_to_find
            {
              date_type: filters_params[:date_type],
              start_date: filters_params[:start_date],
              end_date: filters_params[:end_date],
              amount_type: filters_params[:amount_type],
              total_amount: filters_params[:total_amount],
              status: filters_params[:status],
              store: @store
            }
          end

          def attributes_to_find_client
            {
              start_date: filters_params[:start_date],
              end_date: filters_params[:end_date],
              store: @store
            }
          end
          def find_store
            @store = current_resource_owner.stores.find_by!(uuid: params[:store_uuid])
          end
        end
      end
    end
  end
end
