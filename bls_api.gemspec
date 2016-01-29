# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bls_api/version"

Gem::Specification.new do |spec|
  spec.name          = "bls_api"
  spec.version       = BLS_API::VERSION
  spec.authors       = ["Justin Myers"]
  spec.email         = ["jmyers@ap.org"]

  spec.summary       = %q{API wrapper for data from the U.S. Bureau of Labor Statistics.}
  spec.description   = %q{API wrapper for data from the U.S. Bureau of Labor Statistics.}
  spec.homepage      = "http://ctcinteract-svn01.ap.org/redmine/projects/bls-api"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "climate_control", "~> 0.0.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "rest-client", "~> 1.8"
end
