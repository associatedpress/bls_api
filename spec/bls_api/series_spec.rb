require "spec_helper"

describe BLS_API::Series do
  let(:api_url) { "https://api.bls.gov/publicAPI/v2/timeseries/data/" }

  let(:examples_dir) { File.join(File.dirname(__FILE__), "examples") }
  let(:single_series_json) do
    IO.read(File.join(
      examples_dir, "sae-north_dakota-mining-2014-2015.json"))
  end
  let(:single_series_response) { JSON.parse(single_series_json) }
  let(:catalog_response) do
    JSON.parse(IO.read(File.join(
      examples_dir, "sae-north_dakota-mining-2015-catalog.json")))
  end
  let(:all_options_response) do
    JSON.parse(IO.read(File.join(
      examples_dir, "cps-situation-2015-all_options.json")))
  end

  # Stub API requests.
  before(:each) do
    stub_request(:post, api_url).with(:body => hash_including({
      "seriesid" => ["SMS38000001000000001"],
      "startyear" => "2014",
      "endyear" => "2014",
      "annualaverage" => false,
      "calculations" => false,
      "catalog" => false,
      "registrationKey" => "dummy_api_key"
    })).to_return(:body => single_series_json)
  end

  describe "provides access to series data" do
    let(:series) do
      BLS_API::Series.new(single_series_response["Results"]["series"].first)
    end
    let(:catalog_series) do
      BLS_API::Series.new(catalog_response["Results"]["series"].first)
    end

    it "(series ID)" do
      expect(series.id).to eq("SMS38000001000000001")
    end

    describe "(catalog information)" do
      it "returns nothing if it's unavailable" do
        expect(series.catalog).to be(nil)
      end

      it "returns a catalog if available" do
        expect(catalog_series.catalog.area).to eq("North Dakota")
      end
    end

    it "(month access)" do
      month = series.get_month(2014, 10)
      expect(month.value).to eq(BigDecimal.new("30.9"))
    end

    it "(array access)" do
      expected_month_values = [
        "24.3", "25.3", "25.6", "26.5", "26.5", "27.3", "27.6", "28.0",
        "28.6", "30.0", "31.2", "32.4", "32.1", "31.6", "30.9", "30.8",
        "30.3", "29.7", "29.2", "29.0", "28.8", "28.5", "28.3", "28.0"
      ].map { |x| BigDecimal.new(x) }
      test_month_values = series.monthly.map { |month| month.value }
      expect(test_month_values).to eq(expected_month_values)
    end
  end
end
