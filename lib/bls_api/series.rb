require "ostruct"

require "bls_api/month"

module BLS_API
  class Series
    attr_reader :id

    def initialize(raw_series)
      @id = raw_series["seriesID"]
      @raw_series = raw_series
    end

    # Public: Return catalog information for this series if available.
    #
    # Returns a BLS_API::Catalog if possible; returns nil if no catalog
    #   information was received.
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
      @months.detect do |month|
        month.year == year && month.month == month
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
      @months.sort!
    end
  end
end
