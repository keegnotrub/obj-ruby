# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSArray do
  it "can create an instance" do
    array = described_class.new

    expect(array).not_to be_nil
    expect(array).to be_a described_class
  end

  it "can receive a Ruby array" do
    array = described_class.arrayWithArray([1, 2, 3, 4, 5])

    expect(array.count).to eq 5
    expect(array.indexOfObject(1)).to eq 0
    expect(array.indexOfObject(2)).to eq 1
    expect(array.indexOfObject(3)).to eq 2
    expect(array.indexOfObject(4)).to eq 3
    expect(array.indexOfObject(5)).to eq 4
    expect(array.indexOfObject_inRange(1, ObjRuby::NSRange.new(1, array.count - 1))).to eq ObjRuby::NSNotFound
  end

  it "can receive a variable argument list" do
    array = described_class.arrayWithObjects("here", "there", "everywhere", nil)

    expect(array.count).to eq 3
    expect(array.containsObject("here")).to be true
    expect(array.containsObject("there")).to be true
    expect(array.containsObject("everywhere")).to be true
    expect(array.containsObject("not here")).to be false
    expect(array.indexOfObject("here")).to eq 0
    expect(array.indexOfObject("there")).to eq 1
    expect(array.indexOfObject("everywhere")).to eq 2
    expect(array.indexOfObject("not here")).to eq ObjRuby::NSNotFound
  end

  it "is equal when what it received was equal" do
    array = described_class.arrayWithArray([1, 2, 3, 4, 5])
    manual_array = described_class.arrayWithObjects(1, 2, 3, 4, 5, nil)

    expect(array.isEqualToArray(manual_array)).to be true
  end

  it "can be indexed with a subscript" do
    array = described_class.arrayWithArray([1, 2, "hi", 4, 5])

    expect(array[1]).to eq(2)
    expect(array[2]).to eq("hi")
  end

  it "can be transformed into a Ruby array" do
    array = described_class.arrayWithArray([1, 2, 3, 4, 5])

    result = array.to_a

    expect(result).to be_a Array
    expect(result.size).to eq 5
    expect(result[0]).to eq 1
  end

  it "can use a block method" do
    array = described_class.arrayWithArray([1, 2, 3, 4, 5])

    sum = 0
    array.enumerateObjectsUsingBlock do |x|
      sum += x.to_i
    end

    expect(sum).to eq(1 + 2 + 3 + 4 + 5)
  end

  it "can use a block return method" do
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
