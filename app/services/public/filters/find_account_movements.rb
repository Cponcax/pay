module Public
  module Filters
    class FindAccountMovements
      MORE_OR_EQUAL = 0
      LESS_OR_EQUAL = 1
      EQUAL = 2
      APPROVED = true
      ERROR = false

      def initialize(attributes)
        @date_type= attributes[:date_type]
        @start_date= attributes[:start_date]
        @end_date= attributes[:end_date]
        @amount_type= attributes[:amount_type].to_i
        @total_amount= attributes[:total_amount].to_i * 100
        @status= attributes[:status]
        @store = attributes[:store]
      end

      def call
        @account_movements = @store.account_movements.ransack(ransack_querys).result
      end

      private


      def total_amount
        total = Money.new(c.object, "USD")
        total.format
      end

      def ransack_querys
        att = {}
        case @amount_type
        when MORE_OR_EQUAL
            att[:total_amount_gteq] = @total_amount
          when LESS_OR_EQUAL
            att[:total_amount_lteq] = @total_amount
          when EQUAL
            att[:total_amount_eq] = @total_amount
        end
        unless @status.nil?
          case eval(@status)
          when APPROVED
              @status = "APPROVED"
            when ERROR
              @status = "ERROR"
          end
        end

        att[:payment_status_eq] = @status
        att[:created_date_gteq] = @start_date.to_date if  @start_date
        att[:created_date_lteq] = @end_date.to_date if @end_date
        att
      end
    end
  end
end
