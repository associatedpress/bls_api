require "spec_helper"

describe BLS_API do
  it "has a version number" do
    expect(BLS_API::VERSION).not_to be(nil)
  end
end
