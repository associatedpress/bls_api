module BLS_API
  module Constants
    ENDPOINT_URL = "http://api.bls.gov/publicAPI/v2/timeseries/data/"

    MAX_SERIES_PER_REQUEST = 50
    MAX_YEARS_PER_REQUEST = 20

    MAX_RETRIES = 3
    TIME_BETWEEN_RETRIES = 5  # In seconds
  end
end
