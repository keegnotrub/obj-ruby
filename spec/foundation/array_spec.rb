require "spec_helper"

ObjRuby.import("NSArray")

describe NSArray do
  it "can create an instance" do
    array = described_class.new

    expect(array).to be_a NSArray
    expect(array).not_to be_nil
  end

  it "can call instance methods" do
    array = described_class.arrayWithObject(described_class.new)
    expect(array.count).to eq 1
  end
end
