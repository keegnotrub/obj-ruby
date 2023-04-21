require "spec_helper"

ObjRuby.import("NSArray")

describe NSArray do
  it "can create an instance" do
    array = described_class.new

    expect(array).to be_a NSArray
    expect(array).not_to be_nil
  end

  it "can call instance methods" do
    array = described_class.arrayWithObject("here")
    
    expect(array.count).to eq 1
    expect(array.containsObject("here")).to be true
    expect(array.indexOfObject("not here")).to eq NSNotFound
  end

  it "can receive a Ruby array" do
    array = NSArray.arrayWithRubyArray([1,2,3])
    expect(array.count).to eq 3
  end
end
