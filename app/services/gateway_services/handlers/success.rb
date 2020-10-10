class Success
  attr_reader :response, :obj

  def initialize(response, obj)
    @response = response
    @obj = obj
  end

  def succeed?
    true
  end

  def obj
    @obj
  end
end
