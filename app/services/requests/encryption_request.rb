module Requests
  class EncryptionRequest
    require 'openssl'
    require "base64"

    def initialize(attributes)
      @xml = attributes[:xml]
      @transaction_id = attributes[:transaction_id]
      @api_password = attributes[:api_password]
      @private_key = attributes[:private_key]
      @obj = attributes[:obj]
    end

    def call
      make_signature
      encodedMessage_req
      request_body
    end

    def refund
      {
        make_signature: make_signature_to_refund,
        encodedMessage_req: encodedMessage_req
      }
    end

    def call_to_payment_gateway_upload_docs
      {
        make_signature: make_signature_to_upload_doc,
        encodedMessage_req: encodedMessage_req
      }
    end


    def charge
      {
        make_signature: make_signature_to_charge,
        encodedMessage_req: encodedMessage_req
      }
    end

    def request_body
      @encodedMessage_req = CGI::escape(@encodedMessage_req)
      @signature = CGI::escape(@signature)
      @postdata= "encodedMessage=" + @encodedMessage_req + "&signature="+ @signature
    end


    def encodedMessage_req
      @encodedMessage_req= Base64.encode64(@xml)
    end

    def make_signature
      terminal_password = Rails.application.secrets.terminal_password
      signature_key = terminal_password.to_s + @transaction_id.to_s
      @signature=   Base64.encode64(OpenSSL::HMAC.digest('sha256', signature_key, @xml))
    end

    def make_signature_to_refund
      @signature_key = @obj.store.merchant.private_key.to_s +  @obj.store.merchant.api_password.to_s + @transaction_id
      @signature_key = @signature_key.strip
      @signature=   Base64.encode64(OpenSSL::HMAC.digest('sha256', @signature_key, @xml))
    end

    def make_signature_to_charge
      @signature_key = @obj.merchant.private_key.to_s +  @obj.merchant.api_password.to_s + @transaction_id
      @signature_key = @signature_key.strip
      @signature=   Base64.encode64(OpenSSL::HMAC.digest('sha256', @signature_key, @xml))
    end

    def make_signature_to_upload_doc
      signature_key = @private_key.to_s + @api_password.to_s + @transaction_id.to_s
      @signature=   Base64.encode64(OpenSSL::HMAC.digest('sha256', signature_key, @xml))
    end

  end
end
