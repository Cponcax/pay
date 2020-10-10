module Api
  module Datapaga
    module Dashboard
      module V1
        class DocumentsController < BaseController
          before_action -> { doorkeeper_authorize! :write }
        	before_action :set_store, only: [:create]

          # POST /store/:uuid/docs
          def create
            unless auth_rsa.nil?
              unless @store.nil?

                @result_upload_payment_gateway = ::Merchants::UploadDocument.new(send_doc_to_payment_gateway).call

                @result_upload_card_services = ::Cards::SendDocs.new(send_doc_to_card_services).call

                if @result_upload_payment_gateway[:response] and @result_upload_card_services[:response]
                  DocMailer.notify_of_received_doc(current_resource_owner).deliver_now
                  UpdateKyc.new({store: @store}).call
                  render json: {message: "You files have been upload"}, status: 201
                else
                  render json: {
                                result_upload_card_services:  @result_upload_payment_gateway,
                                result_upload_payment_gateway:  @result_upload_card_services },
                                status: :unprocessable_entity
                end
              else
                render json: {message: "Record not found", error: 404}, status: 404
              end
            end
          end

          def send_doc_payment_gateway
            unless auth_rsa.nil?
              unless @store.nil?
                @result = ::Merchants::UploadDocument.new(send_doc_attributes).call
                if @result.include? :success
                  DocMailer.notify_of_received_doc(current_resource_owner).deliver_now
                  render json: @result, status: 201
                else
                  render json: @result, status: :unprocessable_entity
                end
              else
                render json: {message: "Record not found", error: "404"}, status: 404
              end
            end
          end

          private

          def attributes_to_procces_images
            {
              images_base64: params[:data]
            }
          end

          def convert_images
            images = ProcessTheReceivedImage.new(attributes_to_procces_images).call
            @citizen_id = images[:citizen_id]
            @p_address = images[:p_address]
            @proof_of_home_address =  images[:p_address]
          end
          #
          def  send_doc_to_card_services
            convert_images
            {
              documents_files: {citizen_id: @citizen_id, p_address: @p_address },
              store: @store,
              current_resource_owner: current_resource_owner

            }
          end

          def  send_doc_to_payment_gateway
            convert_images
            {
              documents_files: {proof_of_home_address: @proof_of_home_address},
              store: @store,
              current_resource_owner: current_resource_owner

            }
          end

          def store_params
            params.permit(:citizen_id,
                          :p_address,
                          :p_employment,
                          :bank_info, :p_funds,:income_tax,
                          :uniregistration, :scholarship, :parent_pfunds,
                          :parent_pemployment, :parent_bankstatement,
                          :proof_of_home_address, :bank_details)
          end

          def set_store

            @store = current_resource_owner.stores.find_by!(uuid: params[:store_uuid])
          end
        end
      end
    end
  end
end
