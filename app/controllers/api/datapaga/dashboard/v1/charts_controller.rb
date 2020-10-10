module Api
  module Datapaga
    module Dashboard
      module V1
        class ChartsController < BaseController
          before_action -> { doorkeeper_authorize! :write }
          before_action :set_store, only: [:filters_by_range, :last_seven_days]

          def filters_by_range
            unless auth_rsa.nil?
              unless @store.nil?
                @response = ::Charts::FilterByRange.new(att_filter_by_range).call
                render json: @response, status: :ok
              end
            end
          end

          def last_seven_days
            unless auth_rsa.nil?
              unless @store.nil?
                @response = ::Charts::LastSevenDays.new(att_last_seven_days).call
                render json: @response, status: :ok
              end
            end
          end

          private

          def charts_params
            params.permit(:store_uuid, :start_date, :end_date)
          end

          def att_filter_by_range
            {
              start_date: charts_params[:start_date],
              end_date: charts_params[:end_date],
              store:  @store
            }
          end

          def att_last_seven_days
            {
              store:  @store
            }
          end

          def set_store
            @store = current_resource_owner.stores.find_by!(uuid: charts_params[:store_uuid])
          end
        end
      end
    end
  end
end
