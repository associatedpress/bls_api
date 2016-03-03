require "ostruct"

require "bls_api/month"

module BLS_API
  class Series
    include BLS_API::Destringify

    attr_reader :id

    def initialize(raw_series)
      @id = raw_series["seriesID"]
      begin
        @raw_series = self.destringify_series(raw_series)
      rescue ArgumentError
        # Series was already destringified _and_ it was using Floats.
        @raw_series = raw_series
      end
    end

    # Public: Return catalog information for this series if available.
    #
    # Returns an OpenStruct if possible; returns nil if no catalog information
    #   was received.
    def catalog
      return nil unless @raw_series.include?("catalog")
      return @catalog unless @catalog.nil?
      @catalog = OpenStruct.new(@raw_series["catalog"])
    end

    # Public: Return information for the given month.
    #
    # year  - An Integer representing the year for which to retrieve data.
    # month - An Integer representing the month (1 = January) for which to
    #         retrieve data.
    #
    # Returns a BLS_API::Month.
    def get_month(year, month)
      self.monthly  # Ensure we've converted all months.
      @months.detect do |parsed_month|
        parsed_month.year == year && parsed_month.month == month
      end
    end

    # Public: Return information for all months.
    #
    # Returns an Array of BLS_API::Months.
    def monthly
      return @months unless @months.nil?
      @months = @raw_series["data"].map do |month_data|
        BLS_API::Month.new(month_data)
      end
      @months.sort!.reverse!
    end
  end
end
