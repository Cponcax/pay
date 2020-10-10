class Failure
  attr_reader :response,
              :errors,
              :code

  def initialize(response = {})
    @response= response
    @errors= response[:Description]
    @code= response[:Code]
  end

  def error_message
    @errors
  end

  def error_code
    @code
  end

  def succeed?
    false
  end
end
