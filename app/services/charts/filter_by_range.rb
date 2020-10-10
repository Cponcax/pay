class Charts::FilterByRange
  PAYMENT_STATUS = "APPROVED"

  def initialize(att)
    @start_date= att[:start_date]
    @end_date= att[:end_date]
    @store= att[:store]
  end

  def call
    unless @start_date.nil? && @end_date.nil?
      start_date = @start_date.to_date
      end_date = @end_date.to_date
      range = start_date..end_date
      dates = range.select { |date| date }.flatten
      e = @store.account_movements.where(created_date: start_date..end_date)
                                  .where(payment_status: PAYMENT_STATUS)
                                  .order(created_date: :desc)
      response = []
      count_day = 1

      range.each do |date|
        transactions = e.select { |account_movement| account_movement.created_date == date }
        money = transactions.sum(&:total_amount)
        d = "day_#{count_day}"
        count_day += 1
        sym = d.to_sym
        response << [date.to_s, (money.to_f/100)]
      end

      response
    end 
  end
end
