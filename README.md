# Bureau of Labor Statistics API wrapper #

[![Build Status](https://travis-ci.org/associatedpress/bls_api.svg?branch=master)](https://travis-ci.org/associatedpress/bls_api)
[![Gem Version](https://badge.fury.io/rb/bls_api.svg)](http://badge.fury.io/rb/bls_api)

This is a Ruby wrapper for [v2][v2] of the [BLS Public Data API][bls-dev].

[bls-dev]: http://www.bls.gov/developers/home.htm
[v2]: http://www.bls.gov/developers/api_signature_v2.htm

## Installation ##

    $ gem install bls_api

## Usage ##

    >> require "bls_api"
    >> client = BLS_API::Client.new
    >> data = client.get(:series_ids => ["LNS14000000"], :start_year => 2015, :end_year => 2015)

You'll get back a Hash, with the series IDs you provided as keys. The values
are `BLS_API::Series` instances, which expose the data for each series along
with some BLS-provided metadata:

    >> unemployment_rate = data["LNS14000000"]

    >> unemployment_rate.catalog.series_title
    => "(Seas) Unemployment Rate"
    >> unemployment_rate.catalog.seasonality
    => "Seasonally Adjusted"

    >> june = unemployment_rate.get_month(2015, 6)
    >> june.value.to_f
    => 5.3

### Series metadata ###

`Series#catalog` just returns an [OpenStruct][openstruct] with whatever
metadata the BLS API returned for that series:

    >> unemployment_rate.catalog
    => #<OpenStruct series_title="(Seas) Unemployment Rate",
    series_id="LNS14000000", seasonality="Seasonally Adjusted",
    survey_name="Labor Force Statistics from the Current Population Survey",
    measure_data_type="Percent or rate", commerce_industry="All Industries",
    occupation="All Occupations", cps_labor_force_status="Unemployment rate",
    demographic_age="16 years and over",
    demographic_ethnic_origin="All Origins", demographic_race="All Races",
    demographic_gender="Both Sexes",
    demographic_marital_status="All marital statuses",
    demographic_education="All educational levels">

This is great if you already know what fields to expect; otherwise the more
familiar way to explore it might be as a Hash:

    >> unemployment_rate.catalog.to_h.keys
    => [:series_title, :series_id, :seasonality, :survey_name,
    :measure_data_type, :commerce_industry, :occupation,
    :cps_labor_force_status, :demographic_age, :demographic_ethnic_origin,
    :demographic_race, :demographic_gender, :demographic_marital_status,
    :demographic_education]

[openstruct]: http://ruby-doc.org/stdlib-2.3.0/libdoc/ostruct/rdoc/OpenStruct.html

### Data by month ###

You've already seen `Series#get_month`, which takes a year and month
(1 = January) and returns a `BLS_API::Month`, and you've seen `Month#value`:

    >> june = unemployment_rate.get_month(2015, 6)
    >> june.value.to_f
    => 5.3

You also can get one-, three-, six- or 12-month changes (net changes _or_
percent changes):

    >> june.net_change(1).to_f
    => -0.2
    >> june.percent_change(1).to_f
    => -3.6

These examples use `#to_f` for display purposes because this client uses
[BigDecimal][bigdecimal] instances by default to preserve precision:

    >> june.value
    => #<BigDecimal:7ff5493f5390,'0.53E1',18(18)>

If you'd prefer Floats, you can set `client.use_floats = true` before making
your request:

    >> client.use_floats = true
    >> data = client.get(:series_ids => ["LNS14000000"], :start_year => 2015, :end_year => 2015)
    >> unemployment_rate = data["LNS14000000"]
    >> unemployment_rate.get_month(2015, 6).value
    => 5.3

Also, BLS sometimes provides footnotes for certain data points, which you can
access via `Month#footnotes`:

    >> last_month.footnotes
    => {"P"=>"Preliminary"}

[bigdecimal]: http://ruby-doc.org/stdlib-2.3.0/libdoc/bigdecimal/rdoc/BigDecimal.html

## Configuration ##

You'll need an [API key][api-key], which you can provide as an argument to
`BLS_API::Client.new` or as a `BLS_API_KEY` environment variable. (If you
provide both, the argument to `Client.new` takes precedence.)

[api-key]: http://data.bls.gov/registrationEngine/
