module Api
  module Datapaga
    module Dashboard
      module V1
        module Stores
          class StoresController <  BaseController
            before_action -> { doorkeeper_authorize! :write }
            before_action :set_store, only: [:show, :suspend, :new_store]

            # GET /stores
            def index
              unless auth_rsa.nil?
                # Rails.cache.fetch("#{current_resource_owner.uuid}-stores", expires: 5.minutes) do
                  @stores = current_resource_owner.stores
                # end
                render json: @stores, status: :ok
              end
            end
            # GET /stores/1
            def show
              unless auth_rsa.nil?
               unless @store.nil?
                  render json: [DetailStoreSerializer.new(@store)], status: :ok
               end
              end
            end
            # POST /stores
            def create
              unless auth_rsa.nil?
                  @result = ::Stores::CreateStore.new(current_resource_owner, store_attributes).call
                if @result.succeed?
                  render json: @result
                else
                  render json: @result, status: :unprocessable_entity
                end
              end
            end

            def new_store
              unless auth_rsa.nil?
                @result = ::Stores::NewStore.new(current_resource_owner, @store, new_store_attributes).call
                if @result.succeed?
                  render json: @result
                else
                  render json: @result, status: :unprocessable_entity
                end
              end
            end

            def update
              unless auth_rsa.nil?
                if @store.update(store_params)
                  render json: @store
                else
                  render json: @store.errors, status: :unprocessable_entity
                end
              end
            end

            # DELETE /stores/1
            def destroy
              unless auth_rsa.nil?
                @store.destroy
              end
            end


            # DELETE /stores/1
            def suspend
              unless auth_rsa.nil?
                @result = ::Stores::SuspendStore.new(@store).call
                 render json: @result, status: 201
              end
            end

            private

            def store_attributes
              {
                name: store_params[:name],
                phone: store_params[:phone],
                phone_country_code: store_params[:phone_country_code],
                address_one: store_params[:address_one],
                address_two: store_params[:address_two],
                city: store_params[:city],
                state: store_params[:state],
                country: store_params[:country],
                description: store_params[:description],
                postalcode: store_params[:postalcode],
                web_site_url: store_params[:web_site_url],
                email: current_resource_owner.email

              }
            end

            def new_store_attributes
              {
                name: store_params[:name],
                phone: store_params[:phone],
                phone_country_code: store_params[:phone_country_code],
                city: store_params[:city],
                state: store_params[:state],
                country: store_params[:country],
                description: store_params[:description],
                web_site_url: store_params[:web_site_url],
                email: store_params[:email],
                address_one: store_params[:address_one],
                address_two: store_params[:address_two]

              }
            end


            def card_info_attributes
              {
                user: current_resource_owner,
                card: @card,
                store: @store
              }
            end

          # Use callbacks to share common setup or constraints between actions.
            def set_store
              @store = current_resource_owner.stores.find_by!(uuid: params[:uuid])
            end


            # Only allow a trusted parameter "white list" through.
            def store_params
              params.require(:store).permit(:name,
                                            :description,
                                            :phone,
                                            :phone_country_code,
                                            :address_one,
                                            :address_two,
                                            :city,
                                            :state,
                                            :country,
                                            :postalcode,
                                            :web_site_url,
                                            :identification_type,
                                            :identification_value,
                                            :email)
            end
          end
        end
      end
    end
  end
end
