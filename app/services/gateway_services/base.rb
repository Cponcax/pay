require_relative 'handlers/success'
require_relative 'handlers/failure'
require_relative 'handlers/type_encryption'

module GatewayServices
  class Base
    include Virtus.model(strict: true)
    require 'json'

    class << self
      URL_BASE= 'https://lamda-payments-test.datapaga.com'
      SUCCESS = '0'.freeze
      CHARGE = 'charge'.freeze
      REFUND= 'refund'.freeze
      CREATE_USER= "user".freeze

      def call(*args)
        if respond_to?(:call)
          new().call(*args)
        else
          raise InvalidServiceError
        end
      end

      def get(path, obj, options = {}, template_path)
        transaction_id= Transaction.create!(transactionable_type: "merchant").transaction_id
        attributes_to_encrypt = TypeEncryption.new(options,
                                                  transaction_id,
                                                  template_path,
                                                  obj)
        encrypted_att = attributes_to_encrypt.encrypted

        RestClient.proxy = ENV["QUOTAGUARDSTATIC_URL"] if ENV["QUOTAGUARDSTATIC_URL"]

        response = sanitize RestClient.post(
                                      "#{URL_BASE}#{path}",
                                      {
                                        "encodedMessage" => "#{encrypted_att[:encodedMessage_req]}",
                                        "signature" => "#{encrypted_att[:make_signature]}"
                                      },
                                      #"timeout"=> 1,
                                      "verify_ssl" => true), options

        response
      end

    private

    #sanitize response GatewayServices
      def sanitize(response, options)
        type = options[:type_request]
        case type
        when "refund"
          response = CGI::unescape(response.body).gsub("encodedMessage=", "")
          response=  response.slice(0..(response.index('&')))
          response = Base64.decode64(response)
          response = response.force_encoding("ASCII-8BIT").encode('UTF-8', replace: '', :undef => :replace)
          response = JSON.parse(response, {:symbolize_names => true})
          if  response.has_value?("APPROVED")
           response = Success.new(response, obj= false)
          else
            error_message =  Failure.new(response)
          end
        when "charge"
          html = Nokogiri::HTML(response)
          response = html.at_css("input").attributes["value"].value
          response_decode = Base64.decode64(response)
          response= JSON.parse(response_decode)
          if  response.has_value?("APPROVED")
           Success.new(JSON.parse(response_decode, {:symbolize_names => true}), obj= false)
          else
            Failure.new(JSON.parse(response_decode, {:symbolize_names => true}))
          end
        end
      end
    end

    def call(*args)
      raise NotImplementedError
    end

    #
    # == InvalidServiceError
    #
    # The service doesn't have a call method.
    #
    class InvalidServiceError < StandardError; end

    #
    # == NotImplementedError
    #
    # The service hasn't implemented a call method.
    #
    class NotImplementedError < StandardError; end


    protected

      def success(response, obj)
        Success.new(response, obj)
      end

      def error(response)
        Failure.new(response)
      end
  end
end
