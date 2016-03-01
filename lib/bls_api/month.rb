require "bls_api/errors"

module BLS_API
  class Month
    def initialize(raw_month)
      @raw_month = raw_month
    end

    def year
      @raw_month["year"]
    end

    def month
      @raw_month["period"].slice(/^M(\d+)$/, 1).to_i
    end

    def value
      @raw_month["value"]
    end

    def footnotes
      non_empty_footnotes = @raw_month["footnotes"].reject { |x| x.empty? }
      Hash[non_empty_footnotes.map do |footnote|
        [footnote["code"], footnote["text"]]
      end]
    end

    def net_change(timeframe)
      unless @raw_month.include?("calculations")
        raise BLS_API::NotRetrievedError, "Calculations not retrieved"
      end
      net_changes = @raw_month["calculations"].fetch("net_changes") do
        raise BLS_API::NotRetrievedError, (
          "Net-change calculations not available from BLS")
      end
      net_changes.fetch(timeframe) do
        raise BLS_API::NotRetrievedError, (
          "#{timeframe}-month net changes not available from BLS")
      end
    end

    def percent_change(timeframe)
      unless @raw_month.include?("calculations")
        raise BLS_API::NotRetrievedError, "Calculations not retrieved"
      end
      percent_changes = @raw_month["calculations"].fetch("pct_changes") do
        raise BLS_API::NotRetrievedError, (
          "Percent-change calculations not available from BLS")
      end
      percent_changes.fetch(timeframe) do
        raise BLS_API::NotRetrievedError, (
          "#{timeframe}-month percent changes not available from BLS")
      end
    end

    def <=>(other)
      year_comparison = self.year <=> other.year
      return year_comparison unless year_comparison == 0

      month_comparison = self.month <=> other.month
    end
  end
end
