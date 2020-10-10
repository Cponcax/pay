module Stores
  class FindByEmail < ::BaseService
    ERROR_TITLE = 'Store Error'.freeze

    attribute :email, String, writer: :private

    def initialize(email)
      self.email = email
    end

    def call
    store = Store.find_by(email: email)
    return error(
      title: ERROR_TITLE,
      code: 404,
      message: 'Store not found'
      ) unless store

      success(store)

    rescue => e
     return error(response: e,
                  title: ERROR_TITLE,
                  message: e.message,
                  code: 422)
    end
  end
end
