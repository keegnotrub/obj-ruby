require "spec_helper"

ObjRuby.import("NSArray")

describe ObjRuby::NSArray do
  it "can create an instance" do
    array = described_class.new

    expect(array).not_to be_nil
    expect(array).to be_a described_class
  end

  it "can call instance methods" do
    array = described_class.arrayWithObject("here")

    expect(array.count).to eq 1
    expect(array.containsObject("here")).to be true
    expect(array.containsObject("not here")).to be false
    expect(array.indexOfObject("here")).to eq 0
    expect(array.indexOfObject("not here")).to eq ObjRuby::NSNotFound
  end

  it "can receive a Ruby array" do
    array = described_class.arrayWithArray([1, 2, 3, 4, 5])

    manual_array = described_class.new
    manual_array = manual_array.arrayByAddingObject(1)
    manual_array = manual_array.arrayByAddingObject(2)
    manual_array = manual_array.arrayByAddingObject(3)
    manual_array = manual_array.arrayByAddingObject(4)
    manual_array = manual_array.arrayByAddingObject(5)

    expect(array.count).to eq 5
    expect(array.indexOfObject(1)).to eq 0
    expect(array.indexOfObject_inRange(1, ObjRuby::NSRange.new(1, array.count - 1))).to eq ObjRuby::NSNotFound
    expect(array.isEqualToArray(manual_array)).to be true
  end

  it "can be transformed into a Ruby array" do
    array = described_class.arrayWithArray([1, 2, 3, 4, 5])

    result = array.to_a

    expect(result).to be_a Array
    expect(result.size).to eq 5
    expect(result.first).to eq 1
    expect(result.last).to eq 5
  end
end
