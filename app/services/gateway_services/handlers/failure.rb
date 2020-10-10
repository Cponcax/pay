class Failure
  attr_reader :response,
              :errors

  def initialize(response = {})
    @response= response
    @errors= response[:Description]
  end

  def error_message
    @errors
  end

  def succeed?
    false
  end
end
