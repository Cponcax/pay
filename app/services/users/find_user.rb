module Users
  class FindUser < ::BaseService
    ERROR_TITLE = 'User Error'.freeze

    attribute :id, Integer, writer: :private

    def initialize(id)
      self.id = id
    end

    def call
    user = User.find(id)

    return error(
      title: ERROR_TITLE,
      code: 404,
      message: 'User not found'
      ) unless user

      success(user)

    rescue => e
     return error(response: e,
                  title: ERROR_TITLE,
                  message: e.message,
                  code: 422)
    end
  end
end
