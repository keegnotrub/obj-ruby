require "spec_helper"
require "obj_ruby/foundation"

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

    expect(array.count).to eq 5
    expect(array.indexOfObject(1)).to eq 0
    expect(array.indexOfObject_inRange(1, ObjRuby::NSRange.new(1, array.count - 1))).to eq ObjRuby::NSNotFound
  end

  it "can receive a variable argument list" do
    array = described_class.arrayWithArray([1, 2, 3, 4, 5])
    manual_array = described_class.arrayWithArray([1, 2, 3, 4, 5])

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

  xit "can use a block method" do
    array = described_class.arrayWithArray([1, 2, 3, 4, 5])

    sum = 0
    array.enumerateObjectsUsingBlock do |x|
      sum += x.to_i
    end

    expect(sum).to eq(1 + 2 + 3 + 4 + 5)
  end

  xit "can use a block return method" do
    array1 = described_class.arrayWithArray([1, 2, 3, 4, 5])
    array2 = described_class.arrayWithArray([1, 2, 3, 7, 9])

    result = array1.differenceFromArray_withOptions_usingEquivalenceTest(array2, 0) do |x, y|
      x == y
    end

    expect(result.hasChanges).to be true
    expect(result.insertions.count).to be 2
    expect(result.removals.count).to be 2
  end
end
