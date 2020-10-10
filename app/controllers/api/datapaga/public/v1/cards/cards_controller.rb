module Api
  module Datapaga
    module Public
      module V1
        module Cards
          class CardsController < BaseController
            require 'date'
            before_action :find_store, only: [:index, :show]

            def index
              unless @store.nil?
                @response = ::Public::Cards::List.new(@store).call
                paginate = ::Paginations::Paginate.new(card_params[:page], @response.response)
          
                if paginate.succeed?
                  result = ActiveModelSerializers::SerializableResource.new(paginate.response[:response],
                                                                            each_serializer:  Api::Public::Cards::DetailSerializer).as_json
                  pagination = paginate.response.except(:response)
                  render json: {
                                response: result,
                                current_page:  pagination[:current_page],
                                next_page:  pagination[:next_page],
                                prev_page:  pagination[:prev_page],
                                total_pages:  pagination[:total_pages],
                                total_count:  pagination[:total_count]
                                }
                else
                  render json: {
                                error: {
                                        message: "Record Not Found",
                                         code: "0001"
                                         }
                                        }, status: 404
                end
              else
                render json: {
                              error: {
                                      message: "Record Not Found", code: "0001"
                                      }
                                      }, status: 404
              end
            end

            def show
              @result = ::Public::Cards::FindByUuid.new(params[:uuid], @store).call
              if @result.succeed?
                render json: { response: Api::Public::Cards::CardSerializer.new(@result.response)}, status: :ok
              else
                render json: {
                              error: {
                                      message: "Record Not Found", code: "0001"}}, status: 404
              end
            end

            private

            def card_params
              params.require(:card).permit(
                                            :api_key,
                                            :api_secret,
                                            :start_date,
                                            :end_date,
                                            :uuid,
                                            :page
                                          )
            end

            def find_store
              @store = Store.find_by(api_secret_encoded: card_params[:api_secret])
            end
          end
        end
      end
    end
  end
end
