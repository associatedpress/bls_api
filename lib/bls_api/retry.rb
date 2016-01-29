require "bls_api/constants"
require "bls_api/errors"

module BLS_API
  module Retry
    # Public: Retry a block up to a certain number of times to mitigate the
    # effects of intermittent exceptions.
    #
    # If too many attempts fail, this function will reraise the most recent
    # attempt's last exception.
    #
    # options - A Hash of optional arguments, including:
    #           :max_retries          - An Integer specifying how many times
    #                                   to retry executing the given block
    #                                   after a first failed attempt
    #                                   (default: 3).
    #           :time_between_retries - A Numeric specifying the time, in
    #                                   seconds, to wait between a failed
    #                                   attempt and a subsequent attempt
    #                                   (default: 5 seconds).
    #
    # Returns whatever your block returns.
    def retry(options = {})
      need_block = <<-EOF.gsub(/^ */, "").gsub(/\r?\n/, " ").strip
        #retry needs something to retry! Pass it a block.
      EOF
      raise BLS_API::Errors::ConfigurationError, need_block unless block_given?

      max_retries = options.fetch(
        :max_retries, BLS_API::Constants::MAX_RETRIES)
      time_between_retries = options.fetch(
        :time_between_retries, BLS_API::Constants::TIME_BETWEEN_RETRIES)

      retries = max_retries
      begin
        yield
      rescue StandardError
        if retries > 0
          retries -= 1
          sleep(time_between_retries)
          retry
        end
        raise $!
      end
    end
  end
end
