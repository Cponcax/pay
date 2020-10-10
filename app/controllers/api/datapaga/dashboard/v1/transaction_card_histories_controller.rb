module Api
  module Datapaga
    module Dashboard
      module V1
        class TransactionCardHistoriesController < BaseController
          before_action -> { doorkeeper_authorize! :write }
          before_action :set_store_card, only: [:create]

          # POST /store/:uuid/docs
          def create
            unless auth_rsa.nil?
              unless @store.nil? && @card.nil?
                @result = ::Cards::CardInfo.new(transaction_card_histories_attributes).histories
                unless @result.nil?
                  render json: @result, status: :ok
                else
                  render json: @result, status: :unprocessable_entity
                end
              else
                render json: {message: "Record not found", error: 404}, status: 404
              end
            end
          end

          private

          def transaction_card_histories_params
            params.require(:history).permit(:store_uuid, :card_uuid, :start_date, :end_date)
          end

          def transaction_card_histories_attributes
            {
              store: @store,
              card: @card,
              start_date: transaction_card_histories_params[:start_date],
              end_date: transaction_card_histories_params[:end_date],

            }
          end

          def set_store_card
            @store = Store.find_by(uuid: transaction_card_histories_params[:store_uuid])
            unless @store.nil?
              @card = @store.cards.find_by(uuid: transaction_card_histories_params[:card_uuid])
            end
          end
        end
      end
    end
  end
end
