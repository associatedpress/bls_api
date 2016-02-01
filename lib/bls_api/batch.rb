require "bls_api/constants"

module BLS_API
  module Batch
    # Public: Split a set of series IDs and years 
    def batch(series_ids, start_year, end_year, options = {})
      year_groups = self.get_year_groups(start_year, end_year, options.fetch(
        :max_years, BLS_API::Constants::MAX_YEARS_PER_REQUEST))
      series_groups = self.get_series_groups(series_ids, options.fetch(
        :max_series, BLS_API::Constants::MAX_SERIES_PER_REQUEST))

      # We'll end up with year_groups * series_groups batches (i.e., requests
      # we make to BLS). Prepare an array with a Hash for each batch.
      batches = []
      series_groups.each do |series_group|
        year_groups.each do |year_group|
          start_year, end_year = year_group
          batches << {
            :series_ids => series_group,
            :start_year => start_year,
            :end_year => end_year
          }
        end
      end

      batches
    end

    # Internal: Split series into groups small enough to include in one API
    # request.
    #
    # series_ids  - An Array of String series IDs to split into groups.
    # max_length  - An Integer representing the maximum number of series IDs to
    #               include in one group.
    #
    # Returns an Array of Arrays, each up to `max_length` in length and
    #   containing unchanged objects from `all_series`.
    def get_series_groups(series_ids, max_length)
      series_groups = series_ids.reduce([]) do |groups, series|
        groups << [] if (groups.empty? || groups.last.length >= max_length)
        groups.last << series
        groups
      end
    end

    # Internal: Split years into groups small enough to include in one API
    # request.
    #
    # start_year  - An Integer representing the earliest year to include in
    #               an API request.
    # end_year    - An Integer representing the latest year to include in an
    #               API request.
    # max_length  - An Integer representing the maximum number of series to
    #               include in one group.
    #
    # Returns an Array of Arrays, each containing two Integers: the first
    #   year of a given group and the last year of that group, in that order.
    def get_year_groups(start_year, end_year, max_length)
      all_years = (start_year..end_year).to_a.reverse
      year_groups = all_years.reduce([]) do |groups, series|
        groups << [] if (groups.empty? || groups.last.length >= max_length)
        groups.last << series
        groups
      end
      year_groups.map { |group| [group.last, group.first] }
    end
  end
end
