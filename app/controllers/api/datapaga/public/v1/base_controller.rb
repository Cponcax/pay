module Api
  module Datapaga
    module Public
      module V1
        class BaseController < ApplicationController
          before_action :auth_rsa
          rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

          def doorkeeper_unauthorized_render_options(error: nil)
            { json: { error: 'You shall not pass' } }
          end

          private

          #Find the user that owns the access token
          def current_resource_owner
            @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token && doorkeeper_token.scopes.include?('write')
          end

          def record_not_found
            render json: { error: "Record not Found" }, status: 404
          end

          def auth_rsa
            verify_iss = JwtAuth.new({token: request.headers["HTTP_SECRET"]}).call
          end
        end
      end
    end
  end
end
