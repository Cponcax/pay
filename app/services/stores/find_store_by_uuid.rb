module Stores
  class FindStoreByUuid < ::BaseService
    ERROR_TITLE = 'Store Error'.freeze

    attribute :uuid, String, writer: :private

    def initialize(uuid)
      self.uuid = uuid
    end

    def call
    store = Store.find_by(uuid: uuid)
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
