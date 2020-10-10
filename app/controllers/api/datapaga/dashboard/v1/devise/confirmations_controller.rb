module Api
  module Datapaga
    module Dashboard
      class V1::Devise::ConfirmationsController < DeviseController
        # GET /resource/confirmation?confirmation_token=abcdef
        def show
          self.resource = resource_class.confirm_by_token(params[:confirmation_token])
          yield resource if block_given?

          if resource.errors.empty?
            after_confirmation_path_for
          else
            respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
          end
        end

        protected
        # The path used after resending confirmation instructions.
        def after_resending_confirmation_instructions_path_for

        end

        # The path used after confirmation.
        def after_confirmation_path_for
          apply_mode = 'https://toolbox-dp.herokuapp.com/'
          redirect_to apply_mode, confirm: 'You are being redirected to an external site.'
        end
      end
    end
  end
end
