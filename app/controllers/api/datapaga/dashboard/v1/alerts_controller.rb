module Api
  module Datapaga
    module Dashboard
      module V1
				class AlertsController < BaseController
					before_action -> { doorkeeper_authorize! :write }

					def index
						unless auth_rsa.nil?
					  	render json: active_alerts, status: :ok
					  end
					end

					def active_alerts
						Alert.where("valid_until > ?", DateTime.now)
					end
				end
			end
		end
	end
end
