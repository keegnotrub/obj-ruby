require "spec_helper"

ObjRuby.import("NSArray")

describe NSArray do
  it "can create an instance" do
    array = described_class.new
    
    expect(array).not_to be_nil
    expect(array).to be_a NSArray
  end

  it "can call instance methods" do
    array = described_class.arrayWithObject("here")
    
    expect(array.count).to eq 1
    expect(array.containsObject("here")).to be true
    expect(array.containsObject("not here")).to be false
    expect(array.indexOfObject("here")).to eq 0
    expect(array.indexOfObject("not here")).to eq NSNotFound
  end

  it "can receive a Ruby array" do
    array = described_class.arrayWithArray([1,2,3,4,5])

    manual_array = described_class.new
    manual_array = manual_array.arrayByAddingObject(1)
    manual_array = manual_array.arrayByAddingObject(2)
    manual_array = manual_array.arrayByAddingObject(3)
    manual_array = manual_array.arrayByAddingObject(4)
    manual_array = manual_array.arrayByAddingObject(5)
    
    expect(array.count).to eq 5
    expect(array.indexOfObject(1)).to eq 0
    expect(array.indexOfObject_inRange(1, NSRange.new(1, array.count - 1))).to eq NSNotFound
    expect(array.isEqualToArray(manual_array)).to be true
  end
end
