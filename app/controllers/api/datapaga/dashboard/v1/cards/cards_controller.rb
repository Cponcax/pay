module Api
  module Datapaga
    module Dashboard
      module V1
        module Cards
          class CardsController < BaseController
            ERROR_TITLE = 'Card Error'.freeze

            before_action -> { doorkeeper_authorize! :write }
            before_action :set_card, only: [:card_info, :suspend]
            before_action :set_store, only: [:index,
                                            :balance,
                                            :create,
                                            :selected_card,
                                            :show,
                                            :create_multiple_cards,
                                            :programmed,
                                            :transfer_by_card,
                                            :set_card_default,
                                            :card_info]

            def index
              unless auth_rsa.nil?
                  @cards = ::Cards::List.new(@store).call
                  if @cards.response
                    unless params[:page].nil?
                      @response = @cards.response.page(params[:page].to_i).per(5)
                    else
                      @response = @cards.response.page(1).per(5).order('id asc')
                    end

                    @result = ActiveModelSerializers::SerializableResource.new(@response,
                                                                              each_serializer: CardSerializer).as_json
                    render json: {response: @result,
                                  current_page:  @response.current_page,
                                  next_page:  @response.next_page,
                                  prev_page:  @response.prev_page,
                                  total_pages:  @response.total_pages,
                                  total_count:  @response.total_count},  status: :ok
                else
                  render json: {message: "Cards not found"}, status: 422
                end
              end
            end

            def card_info
              unless auth_rsa.nil?
                unless @store.nil? && @card.nil?
                  @result = ::Cards::CardInfo.new(card_info_attributes).call
                  unless @result.nil?
                    render json: @result, status: :ok
                  else
                    render json: @result, status: :unprocessable_entity
                  end
                else
                  render json: {message: "Record not found", error: "404"}, status: 404
                end
              end
            end

            def show
              unless auth_rsa.nil?

                  @response = ::Cards::FindCard.new(@store, params[:uuid]).call
                  render json: @response,  status: :ok
              end
            end

            def selected_card
              unless auth_rsa.nil?
                @response = ::Cards::FindSelectedCard.new(@store).call

                render json: @response,  status: :ok
              end
            end

            def programmed
              unless auth_rsa.nil?
                @response = ::Cards::CardProgrammed.new(@store, card_programmed_params).call
                render json: @response,  status: :ok
              end
            end

            def transfer_by_card
              unless auth_rsa.nil?
                @response = ::Cards::TransferByCard.new(@store, card_transf_params).call
                if @response
                  render json: @response,  status: :ok
                else
                  render json: {
                                title: ERROR_TITLE,
                                code: 422,
                                message: 'You have exceeded the number of transactions per day'},
                                status: :unprocessable_entity
                end
              end
            end

            def create
              unless auth_rsa.nil?
                response = ::Cards::CreateCard.new(@store).call
                if response.include? :success
                  render json: {message: "Card Crated", code: 201},  status: 201
                else
                  render json: {message: "unprocessable entity"}, status: 422
                end
              end
            end

            def create_multiple_cards
              unless auth_rsa.nil?
                response = ::Cards::MultipleCards.new(current_resource_owner.id,
                                                params[:store_uuid],
                                                params[:number]).call
                if response
                  render json: {message: "Your cards are being processed", code: 201},  status: 201
                else
                  render json: {message: "unprocessable entity"}, status: 422
                end
              end
            end

            def balance
              unless auth_rsa.nil?
                unless @store.nil?
                  @balance = ::Cards::CardBalance.new(att_to_balance).call
                  render json: {amount_balance: @balance}, status: :ok
                end
              end
            end

            def set_card_default
              unless auth_rsa.nil?
                @card = ::Cards::SetCardDefault.new(@store, card_params[:card_uuid]).call
                if @card.succeed?
                  render json: @card, status: :ok
                else
                  render json: @card ,status: :unprocessable_entity
                end
              end
            end


          def suspend
            unless auth_rsa.nil?
              @result = ::Cards::SuspendCard.new(@card).call
              if @result.succeed?
                render json: @result, status: :ok
              else
                render json: @result ,status: :unprocessable_entity
              end
            end
          end


            private

            def card_info_attributes
              {
                user: current_resource_owner,
                card: @card,
                store: @store
              }
            end

            def att_card
             {
               current_resource_owner: current_resource_owner,
               store: @store
             }
            end

             def att_to_balance
               {
                 store: @store,
                 user: current_resource_owner,
                 card: @card,
                 start_date: card_params[:start_date],
                 end_date: card_params[:end_date]
               }
             end

            def card_transf_params
              params.permit(:store_uuid, :card_number, :amount, :card_uuid)
            end

            def card_params
              params.permit(:store_uuid, :start_date, :end_date, :card_uuid)
            end

            def card_programmed_params
              params.permit(:type_of_transfer, :days)
            end


            def set_store
              @store = current_resource_owner.stores.find_by!(uuid: card_params[:store_uuid])
            end

            def set_card
              @card = Card.find_by!(uuid: card_params[:card_uuid])
            end
          end
        end
      end
    end
  end
end
