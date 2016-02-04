# Bureau of Labor Statistics API wrapper #

This is a Ruby wrapper for [v2][v2] of the [BLS Public Data API][bls-dev].

[bls-dev]: http://www.bls.gov/developers/home.htm
[v2]: http://www.bls.gov/developers/api_signature_v2.htm

## Installation ##

    $ gem install bls_api

## Usage ##

    >> require "bls_api"
    >> client = BLS_API::Client.new
    >> data = client.get(:series_ids => ["LNS14000000"], :start_year => 2015, :end_year => 2015)

The data you get back has the structure given in the [BLS API docs][v2], but
with all quantitative values converted from Strings (hard to do math on) to
useful numeric values.

By default, these are [BigDecimal][bigdecimal] instances:

    >> data["Results"]["series"].first["data"].first["value"]
    => #<BigDecimal:7fd93bb39770,'0.55E1',18(18)>

If you'd prefer Floats, you can set `client.use_floats = true` before making
your request:

    >> client.use_floats = true
    >> data = client.get(:series_ids => ["LNS14000000"], :start_year => 2015, :end_year => 2015)
    >> data["Results"]["series"].first["data"].first["value"]
    => 5.5

[bigdecimal]: http://ruby-doc.org/stdlib-2.3.0/libdoc/bigdecimal/rdoc/BigDecimal.html

## Configuration ##

You'll need an [API key][api-key], which you can provide as an argument to
`BLS_API::Client.new` or as a `BLS_API_KEY` environment variable. (If you
provide both, the argument to `Client.new` takes precedence.)

[api-key]: http://data.bls.gov/registrationEngine/
