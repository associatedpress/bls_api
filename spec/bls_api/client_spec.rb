require "spec_helper"

describe BLS_API::Client do
  let(:api_url) { "https://api.bls.gov/publicAPI/v2/timeseries/data/" }
  let(:api_key) { "dummy_api_key" }

  let(:examples_dir) { File.join(File.dirname(__FILE__), "examples") }
  let(:all_options_json) do
    IO.read(File.join(examples_dir, "cps-situation-2015-all_options.json"))
  end
  let(:all_options_response) do
    JSON.parse(all_options_json)
  end
  let(:all_options_destringified) do
    YAML.load(IO.read(File.join(
      examples_dir, "cps-situation-2015-all_options-destringified.yaml")))
  end
  let(:all_options_floats) do
    YAML.load(IO.read(File.join(
      examples_dir,
      "cps-situation-2015-all_options-destringified-use_floats.yaml")))
  end

  describe "accepts an API key" do
    it "via environment variable" do
      ClimateControl.modify(:BLS_API_KEY => api_key) do
        expect do
          client = BLS_API::Client.new
          expect(client.api_key).to eq(api_key)
        end.not_to raise_error
      end
    end

    it "via direct assignment" do
      expect do
        client = BLS_API::Client.new(api_key)
        expect(client.api_key).to eq(api_key)
      end.not_to raise_error
    end

    it "prefers direct assignment" do
      ClimateControl.modify(:BLS_API_KEY => "something-else") do
        expect do
          client = BLS_API::Client.new(api_key)
          expect(client.api_key).to eq(api_key)
        end.not_to raise_error
      end
    end

    it "and complains without one" do
      ClimateControl.modify(:BLS_API_KEY => nil) do
        expect do
          client = BLS_API::Client.new
        end.to raise_error(BLS_API::Errors::ConfigurationError)
      end
    end
  end

  describe ".get" do
    # Stub API requests.
    before(:each) do
      stub_request(:post, api_url).with(:body => hash_including({
        "seriesid" => [
          "LNS14000000", "LNS13000000", "LNS12000000", "LNS11000000"
        ],
        "startyear" => "2015",
        "endyear" => "2015",
        "annualaverage" => true,
        "calculations" => true,
        "catalog" => true,
        "registrationKey" => "dummy_api_key"
      })).to_return(:body => all_options_json)
    end

    let(:destringified_series) do
      all_options_destringified["Results"]["series"]
    end
    let(:client) { BLS_API::Client.new("dummy_api_key") }

    describe "makes and cleans an API call" do
      it "using BigDecimals by default" do
        test_response = client.get(
          :series_ids => [
            "LNS14000000", "LNS13000000", "LNS12000000", "LNS11000000"
          ],
          :start_year => 2015,
          :end_year => 2015,
          :annual_averages => true,
          :calculations => true,
          :catalog => true
        )
        expect(test_response.keys.sort).to eq([
          "LNS11000000", "LNS12000000", "LNS13000000", "LNS14000000"])
        expect(test_response["LNS11000000"]).to be_a(BLS_API::Series)
      end

      it "using Floats if requested" do
        client.use_floats = true
        test_response = client.get(
          :series_ids => [
            "LNS14000000", "LNS13000000", "LNS12000000", "LNS11000000"
          ],
          :start_year => 2015,
          :end_year => 2015,
          :annual_averages => true,
          :calculations => true,
          :catalog => true
        )
        expect(test_response.keys.sort).to eq([
          "LNS11000000", "LNS12000000", "LNS13000000", "LNS14000000"])
        expect(test_response["LNS11000000"]).to be_a(BLS_API::Series)
        test_value = test_response["LNS11000000"].get_month(2015, 10).value
        expect(test_value).to be_a(Float)
      end
    end
  end
end
