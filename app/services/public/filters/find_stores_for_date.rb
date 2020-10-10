module Public
  module Filters
    class FindStoresForDate
      def initialize(attributes)
        @api_key= attributes[:api_key],
        @api_secret= attributes[:api_secret],
        @start_date= attributes[:start_date],
        @end_date= attributes[:end_date]
      end

      def find_store
        @store= Store.find_by(api_secret_encoded: @api_secret)
        unless @store.nil?
          if (@start_date.present? and @end_date.present?)
            if date_valid?(@start_date.to_s) and date_valid?(@end_date.to_s)
              @start_date=    @start_date.to_date
              @end_date= @end_date.to_date
              accs = Arel::Table.new(:account_movements)
              @account_movements= @store.account_movements.where(accs[:created_date].gteq @start_date)
                                                          .where(accs[:created_date].lteq @end_date)
              response= {
                account_movements: @account_movements,
                success: true
              }
            else
             {message: "Invalid Date", invalid: true}
            end
          else
            {
              account_movements: @store.account_movements,
              success: true
            }
          end
        else
          {success: false }
        end
      end

      def date_valid?(date)
        DateTime.strptime(date, "%F")
        true
      rescue ArgumentError
        false
      end
    end
  end
end
