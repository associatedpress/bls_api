require "bls_api/constants"
require "bls_api/destringify"
require "bls_api/errors"
require "bls_api/raw_request"

module BLS_API
  class Client
    include BLS_API::Destringify
    include BLS_API::RawRequest

    attr_accessor :api_key
    attr_accessor :request_annual_averages
    attr_accessor :request_catalog
    attr_accessor :request_calculations
    attr_accessor :use_floats

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

      @request_annual_averages = true
      @request_catalog = true
      @request_calculations = true
      @use_floats = false
    end

    # Public: Request a batch of data from the BLS API.
    #
    # By default, raises BLS_API::Errors::APIError if the request is
    # unsuccessful. (You can catch this with an IOError, if that's more your
    # thing.)
    #
    # options - A Hash with three required arguments and four optional
    #           arguments.
    #           Required arguments include:
    #           :series_ids - An Array of String series IDs for which to
    #                         request data. If a String is provided instead, it
    #                         is assumed to be a single series ID.
    #           :start_year - An Integer representing the earliest year for
    #                         which to request data.
    #           :end_year   - An Integer representing the latest year for which
    #                         to request data. Note that the BLS API will
    #                         return an error if you specify a year for which
    #                         no data exists; for example, an :end_year of 2016
    #                         will raise an error during January of 2016 when
    #                         no 2016 data has yet been released.
    #           Optional arguments include:
    #           :catch_errors     - A Boolean specifying whether to raise an
    #                               APIError if the request is unsuccessful
    #                               (default: true).
    #           :catalog          - A Boolean specifying whether to include
    #                               catalog data in the response
    #                               (default: true).
    #           :calculations     - A Boolean specifying whether to include
    #                               net-change and percent-change calculations
    #                               in the response (default: true).
    #           :annual_averages  - A Boolean specifying whether to include
    #                               annual averages in the response
    #                               (default: true).
    #
    # Returns a Hash of the parsed JSON response from the API, with numeric
    #   strings converted to BigDecimals.
    def get(options = {})
      raw_response = self.make_api_request(options)
      self.destringify(raw_response, @use_floats)
    end
  end
end
