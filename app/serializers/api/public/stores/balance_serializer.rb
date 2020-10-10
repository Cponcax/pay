module Api
  module Public
    module Stores
      class BalanceSerializer < ActiveModel::Serializer
        attributes  :balance

        def balance
          total = Money.new(object.response.balance, "USD")
          total.format
        end
      end
    end
  end
end
