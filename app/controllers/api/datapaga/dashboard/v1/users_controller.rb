module Api
  module Datapaga
    module Dashboard
      module V1
        class UsersController <  BaseController
          before_action -> { doorkeeper_authorize! :write }, except: [:login, :forgot_password, :update_password_forgot]
          before_action :set_user, only: [:show, :update, :destroy, :update_password, :active_user,
                                          :desactive_user]
          before_action :find_user, only: [:login, :forgot_password]
          before_action :set_store_uuid, only: [:login]
          before_action :find_user_by_token_reset, only: [:update_password_forgot]

          def index
            unless auth_rsa.nil?
              @users = User.all
              render json: @users
            end
          end

          def login
            unless auth_rsa.nil?
              unless @user.blank?
                if  @user.valid_password?(params[:user][:password])
                  unless @user.stores.blank?
                    CardWorker.perform_async(@user.id)
                    kyc = @user.stores.last.kyc
                  end
                    @user.create_access_token
                    render json: {
                                  token: @user.token.token,
                                  refresh_token: @user.token.refresh_token,
                                  active: @user.active,
                                  store_uuid: @store_uuid,
                                  kyc: kyc},status: :ok

                else
                  render json: {message: "Password or email invalid", status: 401}, status: :unauthorized
                end
              else
                render json: {message: "Password or email invalid", status: 401}, status: :unauthorized
              end
            end
          end

          def me
            unless auth_rsa.nil?
              render json: current_resource_owner
            end
          end

          def update
            unless auth_rsa.nil?
              if @user.update_attributes(user_params)
                @user.update_attributes(active: true)
                render json: {active: @user.active , message: "User was successfully updated"}, status: :ok
              else
                render json: @user.errors, status: :unprocessable_entity
              end
            end
          end

          def desactive_user
            unless auth_rsa.nil?
              if @user.update_attributes(active: false)
                render json: {active: @user.active , message: "User  was successfully deactivate"}, status: :ok
              else
                render json: @user.errors, status: :unprocessable_entity
              end
            end
          end

          def active_user
            unless auth_rsa.nil?
              if @user.update_attributes(active: true)
                render json: {active: @user.active , message: "User  was successfully true"}, status: :ok
              else
                render json: @user.errors, status: :unprocessable_entity
              end
            end
          end

         def update_password
            unless auth_rsa.nil?
              @user = current_resource_owner
              if @user.update_with_password(user_params)
                render json:  {message: "password was successfully", code: "ok"}, status: :ok
              else
                render json: @user.errors, status: :unprocessable_entity
              end
            end
         end

         def update_password_forgot
            unless auth_rsa.nil?
              if @user.update_attributes(password: params[:user][:password],
                                        password_confirmation: params[:user][:password_confirmation])
                render json:  {message: "password was successfully", code: "ok"}, status: :ok
              else
                render json: @user.errors, status: :unprocessable_entity
              end
            end
         end

         def forgot_password
            unless auth_rsa.nil?
              unless @user.nil?
                @user.send_reset_password_instructions
                render json: {message: "Mail is send_reset_password_instructions "}
              end
            end
          end


        private

          def find_user_by_token_reset
            @user = User.find_by(reset_password_token: params[:reset_password_token])
          end

          def find_user
            @user = User.find_by!(email: params[:user][:email])
          end

          def set_store_uuid
            if @user.present? and @user.stores.present?
              @store_uuid = @user.stores.last.uuid
            end
          end

          def set_user
            @user = current_resource_owner
          end

          def user_params
            params.require(:user).permit(
                                          :first_name,
                                          :last_name,
                                          :postalcode,
                                          :email,
                                          :birthday,
                                          :active,
                                          :password,
                                          :password_confirmation,
                                          :current_password,
                                          :nationality,
                                          :identification_type,
                                          :identification_value,
                                          :title,
                                          :user_name
                                        )
          end
        end
      end
    end
  end
end
