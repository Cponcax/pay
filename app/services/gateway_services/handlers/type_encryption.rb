class TypeEncryption
  attr_reader :type, :transaction_id, :template_path

  def initialize(options, transaction_id, template_path, obj)
    @type = options[:type_request]
    @transaction_id = transaction_id
    @template_path = template_path
    @obj = obj
    @options = options
  end

  def encrypted
    case @type
    when "charge"
      ::Requests::EncryptionRequest.new(
                                          {
                                            xml: @template_path.new(@obj,
                                                                    @options,
                                                                    @transaction_id).call,
                                            transaction_id: @transaction_id,
                                            obj: @obj
                                          }).charge
    when "refund"
      ::Requests::EncryptionRequest.new(
                                          {
                                            xml: @template_path.new(@obj,
                                                                    @options,
                                                                    @transaction_id).call,
                                            transaction_id: @transaction_id,
                                            obj: @obj
                                          }).refund
    end
  end
end
