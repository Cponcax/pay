module Stores
  class SuspendStore < ::BaseService
    ERROR_TITLE = 'Store Error'.freeze

    attribute :store, ActionController::Parameters, writer: :private


    def initialize(store)
      self.store = store
    end

    def call
      store.update!(suspended: true)
      success(store)

      rescue ActiveRecord::RecordInvalid => e
        return error(response: e.record, title: ERROR_TITLE, code: 422,
                     message: 'Store could not be created', errors: e.record.errors)
      rescue => e
        return error(response: e, title: ERROR_TITLE, message: e.message, code: 422)
    end
  end
end
