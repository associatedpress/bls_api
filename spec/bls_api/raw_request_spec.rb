require "spec_helper"

describe BLS_API::RawRequest do
  class Requestor
    include BLS_API::RawRequest
    def api_key
      "dummy_api_key"
    end
  end
  let(:requestor) { Requestor.new }

  let(:api_url) { "http://api.bls.gov/publicAPI/v2/timeseries/data/" }

  let(:examples_dir) { File.join(File.dirname(__FILE__), "examples") }
  let(:single_series_response) do
    IO.read(File.join(examples_dir, "sae-north_dakota-mining-2014-2015.json"))
  end
  let(:multi_series_response) do
    IO.read(File.join(examples_dir, "cps-situation-2015.json"))
  end
  let(:bad_end_year_response) do
    IO.read(File.join(examples_dir, "bad_end_year.json"))
  end

  # Stub API requests.
  before(:each) do
    stub_request(:post, api_url).with(:body => hash_including({
      "seriesid" => ["SMS38000001000000001"],
      "startyear" => "2014",
      "endyear" => "2015",
      "annualaverage" => false,
      "calculations" => false,
      "catalog" => false,
      "registrationKey" => "dummy_api_key"
    })).to_return(:body => single_series_response)

    stub_request(:post, api_url).with(:body => hash_including({
      "seriesid" => [
        "LNS14000000", "LNS13000000", "LNS12000000", "LNS11000000"
      ],
      "startyear" => "2015",
      "endyear" => "2015",
      "annualaverage" => false,
      "calculations" => false,
      "catalog" => false,
      "registrationKey" => "dummy_api_key"
    })).to_return(:body => multi_series_response)

    stub_request(:post, api_url).with(:body => hash_including({
      "endyear" => "2017",
    })).to_return(:body => bad_end_year_response)
  end

  describe ".make_api_request" do
    describe "handles arguments" do
      describe "that are required" do
        it ":series_ids" do
          expect do
            requestor.make_api_request(
              :start_year => 2015, :end_year => 2015)
          end.to raise_error(BLS_API::Errors::OptionsError, "Missing series IDs")
        end

        it ":start_year" do
          expect do
            requestor.make_api_request(
              :series_ids => ["foo"], :end_year => 2015)
          end.to raise_error(BLS_API::Errors::OptionsError, "Missing start year")
        end

        it ":end_year" do
          expect do
            requestor.make_api_request(
              :series_ids => ["foo"], :start_year => 2015)
          end.to raise_error(BLS_API::Errors::OptionsError, "Missing end year")
        end
      end
    end

    describe "requests series" do
      it "with a string series ID" do
        response = requestor.make_api_request(
          :series_ids => "SMS38000001000000001",
          :start_year => 2014,
          :end_year => 2015,
          :catalog => false,
          :calculations => false,
          :annual_averages => false)

        expected_series_ids = ["SMS38000001000000001"]
        test_series_ids = response["Results"]["series"].map do |series|
          series["seriesID"]
        end.sort
        expect(test_series_ids).to eq(expected_series_ids)
      end

      it "with an Array of IDs" do
        response = requestor.make_api_request(
          :series_ids => [
            "LNS14000000", "LNS13000000", "LNS12000000", "LNS11000000"
          ],
          :start_year => 2015,
          :end_year => 2015,
          :catalog => false,
          :calculations => false,
          :annual_averages => false)

        expected_series_ids = [
          "LNS11000000", "LNS12000000", "LNS13000000", "LNS14000000"
        ]
        test_series_ids = response["Results"]["series"].map do |series|
          series["seriesID"]
        end.sort
        expect(test_series_ids).to eq(expected_series_ids)
      end
    end

    describe "handles errors" do
      it "with an APIError by default" do
        expect do
          response = requestor.make_api_request(
            :series_ids => [
              "LNS14000000", "LNS13000000", "LNS12000000", "LNS11000000"
            ],
            :start_year => 2015,
            :end_year => 2017)
        end.to raise_error(
          BLS_API::Errors::APIError,
          (
            "BLS API returned an error: REQUEST_FAILED_INVALID_PARAMETERS " +
            "Additional messages were: \"End year is invalid.\""))
      end

      it "with the raw response if requested" do
        expect do
          response = requestor.make_api_request(
            :series_ids => [
              "LNS14000000", "LNS13000000", "LNS12000000", "LNS11000000"
            ],
            :start_year => 2015,
            :end_year => 2017,
            :catch_errors => false)
          expect(response["status"]).to eq("REQUEST_FAILED_INVALID_PARAMETERS")
          expect(response["message"]).to eq(["End year is invalid."])
        end.not_to raise_error
      end
    end
  end
end
