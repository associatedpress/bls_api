module BLS_API
  module Errors
    class APIError < IOError; end
    class ConfigurationError < ArgumentError; end
    class OptionsError < ArgumentError; end
  end
end
