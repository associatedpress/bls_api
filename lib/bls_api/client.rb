require "bls_api/errors"

module BLS_API
  class Client
    attr_accessor :api_key

    def initialize(api_key = nil)
      @api_key = ENV.fetch("BLS_API_KEY", nil)
      @api_key = api_key unless api_key.nil?
      @api_key = nil if @api_key.is_a?(String) && @api_key.empty?
      if @api_key.nil?
        missing_key_message = <<-EOF.gsub(/^ */, "").gsub(/\r?\n/, " ").strip
          You must provide an API key as an argument to BLS_API::Client.new or
          as the BLS_API_KEY environment variable. If you do not have an API
          key, register for one at http://data.bls.gov/registrationEngine/.
        EOF
        raise BLS_API::Errors::ConfigurationError, missing_key_message
      end
    end
  end
end
