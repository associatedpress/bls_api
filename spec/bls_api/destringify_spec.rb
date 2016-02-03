require "spec_helper"

describe BLS_API::Destringify do
  class Destringifier
    include BLS_API::Destringify
  end
  let(:destringifier) { Destringifier.new }

  let(:examples_dir) { File.join(File.dirname(__FILE__), "examples") }
  let(:all_options_response) do
    JSON.parse(IO.read(File.join(
      examples_dir, "cps-situation-2015-all_options.json")))
  end
  let(:all_options_destringified) do
    YAML.load(IO.read(File.join(
      examples_dir, "cps-situation-2015-all_options-destringified.yaml")))
  end

  let(:labor_force_201510) do
    JSON.parse(
      <<-EOF
        {
          "year": "2015",
          "period": "M10",
          "periodName": "October",
          "value": "157096",
          "footnotes": [
            {
            }
          ],
          "calculations": {
            "net_changes": {
              "1": "229",
              "3": "-19",
              "6": "64",
              "12": "733"
            },
            "pct_changes": {
              "1": "0.1",
              "3": "0.0",
              "6": "0.0",
              "12": "0.5"
            }
          }
        }
      EOF
    )
  end

  describe ".destringify" do
    it "destringifies an entire API response" do
      test_response = destringifier.destringify(all_options_response)
      expect(test_response).to eq(all_options_destringified)
    end
  end

  describe ".destringify_calculations" do
    it "converts number keys and values in a calculations object" do
      expected_calcs = {
        1 => BigDecimal.new("229"),
        3 => BigDecimal.new("-19"),
        6 => BigDecimal.new("64"),
        12 => BigDecimal.new("733")
      }
      test_calcs = destringifier.destringify_calculations(
        labor_force_201510["calculations"]["net_changes"])
      
      expect(test_calcs).to eq(expected_calcs)
    end
  end

  describe ".destringify_month" do
    it "converts number Strings in a month object" do
      expected_month = {
        "year" => 2015,
        "period" => "M10",
        "periodName" => "October",
        "value" => BigDecimal.new("157096"),
        "footnotes" => [{}],
        "calculations" => {
          "net_changes" => {
            1 => BigDecimal.new("229"),
            3 => BigDecimal.new("-19"),
            6 => BigDecimal.new("64"),
            12 => BigDecimal.new("733")
          },
          "pct_changes" => {
            1 => BigDecimal.new("0.1"),
            3 => BigDecimal.new("0.0"),
            6 => BigDecimal.new("0.0"),
            12 => BigDecimal.new("0.5")
          }
        }
      }
      test_month = destringifier.destringify_month(labor_force_201510)
      
      expect(test_month).to eq(expected_month)
    end

    it "converts months without calculations" do
      labor_force_201510.delete("calculations")

      expected_month = {
        "year" => 2015,
        "period" => "M10",
        "periodName" => "October",
        "value" => BigDecimal.new("157_096"),
        "footnotes" => [{}]
      }
      test_month = destringifier.destringify_month(labor_force_201510)
      
      expect(test_month).to eq(expected_month)
    end
  end

  describe ".destringify_series" do
    it "destringifies an entire API response" do
      raw_series = all_options_response["Results"]["series"].first
      expected_series = all_options_destringified["Results"]["series"].first
      test_series = destringifier.destringify_series(raw_series)
      expect(test_series).to eq(expected_series)
    end
  end
end