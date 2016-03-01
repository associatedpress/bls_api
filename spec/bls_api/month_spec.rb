require "spec_helper"

describe BLS_API::Month do
  let(:prelim_month_raw) do
    {
      "year" => 2015,
      "period" => "M12",
      "periodName" => "December",
      "value" => BigDecimal.new("24.3"),
      "footnotes" => [
        {
          "code" => "P",
          "text" => "Preliminary"
        }
      ]
    }
  end
  let(:prelim_month) { BLS_API::Month.new(prelim_month_raw) }

  let(:basic_month_raw) do
    {
      "year" => 2014,
      "period" => "M03",
      "periodName" => "March",
      "value" => BigDecimal.new("28.5"),
      "footnotes" => [{}]
    }
  end
  let(:basic_month) { BLS_API::Month.new(basic_month_raw) }

  let(:calc_month_raw) do
    {
      "year" => 2015,
      "period" => "M10",
      "periodName" => "October",
      "value" => BigDecimal.new("7899"),
      "footnotes" => [{}],
      "calculations" => {
        "net_changes" => {
          1 => BigDecimal.new("-26"),
          3 => BigDecimal.new("-350"),
          6 => BigDecimal.new("-624"),
          12 => BigDecimal.new("-1090")
        },
        "pct_changes" => {
          1 => BigDecimal.new("-0.3"),
          3 => BigDecimal.new("-4.2"),
          6 => BigDecimal.new("-7.3"),
          12 => BigDecimal.new("-12.1")
        }
      }
    }
  end
  let(:calc_month) { BLS_API::Month.new(calc_month_raw) }

  it "exposes year" do
    expect(prelim_month.year).to eq(2015)
  end

  it "exposes month" do
    expect(prelim_month.month).to eq(12)
    expect(basic_month.month).to eq(3)
  end

  it "exposes value" do
    expect(prelim_month.value).to eq(BigDecimal.new("24.3"))
  end

  it "exposes footnotes" do
    expect(prelim_month.footnotes).to eq({"P" => "Preliminary"})
    expect(basic_month.footnotes).to eq({})
  end

  it "exposes calculations" do
    expect(calc_month.net_change(1)).to eq(BigDecimal.new("-26"))
    expect(calc_month.percent_change(6)).to eq(BigDecimal.new("-7.3"))
  end

  it "compares by date" do
    expect(prelim_month <=> basic_month).to eq(1)
  end
end
