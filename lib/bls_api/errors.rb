module BLS_API
  module Errors
    class APIError < IOError; end
    class ConfigurationError < ArgumentError; end
    class NotRetrievedError < KeyError; end
    class OptionsError < ArgumentError; end
  end
end
