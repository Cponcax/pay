module Requests
  class GenerateRequest
    require 'faraday'
    require 'openssl'
    require "base64"

    def initialize(attributes)
      @url = attributes[:url]
      @xml = attributes[:xml]
      @transaction_id = attributes[:transaction_id]
    end

    def call
      body = CGI::unescape(response.body).gsub("encodedMessage=", "")
      body = Base64.decode64(body)
      #remove invalid chart
      xml_request = body.force_encoding("ASCII-8BIT").encode('UTF-8', replace: '', :undef => :replace)
      #sorting out xml
      response_xml = Nokogiri.XML(xml_request)
      #parse xml to Json
      @response_json = Hash.from_xml(response_xml.to_s)

    end

    def response
      Faraday.post(@url, request_body)
    end

    private

    def request_body
      ::Requests::EncryptionRequest.new(attributes_to_encrypt).call
    end

    def attributes_to_encrypt
      {
        xml: @xml,
        transaction_id: @transaction_id
      }
    end
  end
end
