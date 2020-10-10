module Public
  module Merchants
    class FindByEmail < ::BaseService
      ERROR_TITLE = 'Merchant Error'.freeze

      attribute :email, String, writer: :private

      def initialize(email)
        self.email = email
      end

      def call
      card = Merchant.find_by(email: email)
      return error(
        title: ERROR_TITLE,
        code: 404,
        message: 'Merchant not found'
        ) unless card

        success(card)

      rescue => e
       return error(response: e,
                    title: ERROR_TITLE,
                    message: e.message,
                    code: 422)
      end
    end
  end
end
