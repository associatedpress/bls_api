require "bigdecimal"

module BLS_API
  module Destringify
    # Public: Convert numeric data in a BLS API response from Strings to
    # instances of more useful Numeric subclasses for the user's convenience.
    #
    # (My guess is BLS sends data as strings in order to maintain precision and
    # simplify the JSON conversion on their end.)
    #
    # raw_response  - A Hash of parsed JSON data from an API response, such as
    #                 that returned by BLS_API::RawRequest#make_api_request.
    #
    # Returns a Hash similar to raw_response but with some keys and values
    #   converted to Numerics.
    def destringify(raw_response)
      output = {}

      raw_response.keys.reject { |key| key == "Results" }.each do |key|
        output[key] = raw_response[key]
      end

      output_results = {}
      output["Results"] = output_results
      raw_results = raw_response["Results"]
      raw_results.keys.reject { |key| key == "series" }.each do |key|
        output_results[key] = raw_results[key]
      end

      output_results["series"] = raw_results["series"].map do |raw_series|
        self.destringify_series(raw_series)
      end

      output
    end

    # Internal: Convert the keys and values in a calculations object (change in
    # an indicator over the past {1,3,6,12} months) from Strings to Numerics.
    #
    # raw_calcs - A Hash with String keys (specifying the number of months over
    #             which a given change was calculated) and String values
    #             (specifying the change over that period of time).
    #
    # Returns a Hash with Integer keys and BigDecimal values (to preserve
    #   precision).
    def destringify_calculations(raw_calcs)
      Hash[raw_calcs.each_pair.map do |key, value|
        [key.to_i, BigDecimal.new(value)]
      end]
    end

    # Internal: Convert all quantitative keys and values in a month object
    # (statistics and optional changes corresponding to a particular
    # series/month combination) from Strings to Numerics.
    #
    # raw_month - A Hash for a given month's data point. Should contain "year",
    #             "period" and "value" properties, at least.
    #
    # Returns a Hash with all of the same keys as `raw_month`.
    def destringify_month(raw_month)
      output = {}

      output["year"] = raw_month["year"].to_i
      output["value"] = BigDecimal.new(raw_month["value"])

      if raw_month.include?("calculations")
        output["calculations"] = Hash[
          raw_month["calculations"].each_pair.map do |name, calcs|
            [name, self.destringify_calculations(calcs)]
          end
        ]
      end

      keys_to_pass_through = raw_month.keys.reject do |key|
        ["year", "value", "calculations"].include?(key)
      end
      keys_to_pass_through.each { |key| output[key] = raw_month[key] }

      output
    end

    # Internal: Convert numeric data in a BLS API series from Strings to
    # Numerics.
    #
    # raw_series  - An Array of month Hashes from a BLS API response.
    #
    # Returns an Array of month Hashes after conversion by #destringify_month.
    def destringify_series(raw_series)
      output = {}

      raw_series.keys.reject { |key| key == "data" }.each do |key|
        output[key] = raw_series[key]
      end

      output["data"] = raw_series["data"].map do |raw_month|
        self.destringify_month(raw_month)
      end

      output
    end
  end
end
