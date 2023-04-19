require "spec_helper"

ObjRuby.import("NSArray")

describe NSArray do
  it "can create an instance" do
    array = described_class.new

    expect(array).to be_a NSArray
    expect(array).not_to be_nil
  end

  it "can call instance methods" do
    nested_array = described_class.new
    array = described_class.arrayWithObject(nested_array)
    
    expect(array.count).to eq 1
    expect(array.containsObject(nested_array)).to be true
  end

  it "can receive a Ruby array" do
    array = NSArray.arrayWithRubyArray([1,2,3])
    expect(array.count).to eq 3
  end
end
