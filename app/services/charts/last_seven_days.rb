class Charts::LastSevenDays
  PAYMENT_STATUS = "APPROVED".freeze

  def initialize(att)
    @store = att[:store]
  end

  def call
    calculate_days
    range = @week_ago..@current_day
    range_of_dates = range.map {|c| c}
    response =[]
    count_day = 1
    range_of_dates.each do |day|
      account_movements = @store.account_movements.where({created_date: day, 
                                                          payment_status: PAYMENT_STATUS})
      money= account_movements.sum {|t| t.total_amount.to_f/100}
      d = "#{count_day}"
      count_day += 1
      sym = d.to_sym
      response << [day.to_s.to_date, money]
    end
    response
  end

  private

  def calculate_days
    @current_day = Date.current
    @week_ago =   @current_day -6
  end
end
