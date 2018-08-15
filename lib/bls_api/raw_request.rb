require "json"
require "net/http"

require "bls_api/constants"
require "bls_api/errors"

module BLS_API
  module RawRequest
    # Internal: Request a batch of data from the BLS API.
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
    # Returns a Hash of the parsed JSON response from the API.
    def make_api_request(options = {})
      # Ensure required arguments are provided.
      series_ids = options.fetch(:series_ids) do
        raise BLS_API::Errors::OptionsError, "Missing series IDs"
      end
      series_ids = [series_ids] if series_ids.is_a?(String)
      start_year = options.fetch(:start_year) do
        raise BLS_API::Errors::OptionsError, "Missing start year"
      end
      end_year = options.fetch(:end_year) do
        raise BLS_API::Errors::OptionsError, "Missing end year"
      end

      # Build and make the API request.
      endpoint_uri = URI.parse(BLS_API::Constants::ENDPOINT_URL)
      req = Net::HTTP::Post.new(endpoint_uri.path)
      req.body = {
        "seriesid" => series_ids,
        "startyear" => start_year.to_s,
        "endyear" => end_year.to_s,
        "annualaverage" => options.fetch(:annual_averages, true),
        "calculations" => options.fetch(:calculations, true),
        "catalog" => options.fetch(:catalog, true),
        "registrationKey" => self.api_key
      }.to_json
      req.content_type = "application/json"
      res = Net::HTTP.start(
        endpoint_uri.host, endpoint_uri.port,
        :use_ssl => endpoint_uri.scheme == "https"
      ) do |http|
        http.request(req)
      end

      # Let the user know if the API request failed.
      parsed = JSON.parse(res.body)
      catch_errors = options.fetch(:catch_errors, true)
      if catch_errors && parsed["status"] != "REQUEST_SUCCEEDED"
        error_messages = %Q{"#{parsed["message"].join(%Q{", "})}"}
        error_message = <<-EOF.gsub(/^ */, "").gsub(/\r?\n/, " ").strip
          BLS API returned an error: #{parsed["status"]}
          Additional messages were: #{error_messages}
        EOF
        raise BLS_API::Errors::APIError, error_message
      end

      # Return the whole API response.
      parsed
    end
  end
end
