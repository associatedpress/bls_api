require "spec_helper"

describe BLS_API::Client do
  describe "accepts an API key" do
    let(:api_key) { "dummy_api_key" }

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
end
