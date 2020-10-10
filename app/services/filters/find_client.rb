module Filters
  class FindClient
    def initialize(attributes)
      @start_date= attributes[:start_date]
      @end_date= attributes[:end_date]
      @store = attributes[:store]
    end

    def call
      @account_movements = @store.account_movements.ransack(ransack_querys).result
      @account_movements.select(:client_email).distinct.count
    end

    private

    def ransack_querys
      {
        created_date_gteq: @start_date,
        created_date_lteq: @end_date
      }
    end
  end
end
