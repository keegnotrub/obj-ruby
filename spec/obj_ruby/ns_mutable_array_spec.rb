# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSMutableArray do
  it "can create an instance" do
    array = described_class.new

    expect(array).not_to be_nil
    expect(array).to be_a described_class
  end

  it "can add objects" do
    array = described_class.new

    expect do
      array << "one"
      array << "two"
      array << "three"
    end.to change(array, :count).by(3)

    expect(array[0]).to eq ObjRuby::NSString("one")
    expect(array[1]).to eq ObjRuby::NSString("two")
    expect(array[2]).to eq ObjRuby::NSString("three")
  end

  it "can add objects by indexed subscript" do
    array = described_class.new

    expect do
      array[0] = "one"
      array[1] = "two"
      array[2] = "three"
    end.to change(array, :count).by(3)

    expect(array[0]).to eq ObjRuby::NSString("one")
    expect(array[1]).to eq ObjRuby::NSString("two")
    expect(array[2]).to eq ObjRuby::NSString("three")
  end

  it "can replace objects" do
    array = described_class.arrayWithArray([1, 2, 3])

    expect do
      array.replaceObjectAtIndex_withObject(0, "one")
      array.replaceObjectAtIndex_withObject(1, "two")
      array.replaceObjectAtIndex_withObject(2, "three")
    end.not_to change(array, :count)

    expect(array[0]).to eq ObjRuby::NSString("one")
    expect(array[1]).to eq ObjRuby::NSString("two")
    expect(array[2]).to eq ObjRuby::NSString("three")
  end

  it "can replace objects by indexed subscript" do
    array = described_class.arrayWithArray([1, 2, 3])

    expect do
      array[0] = "one"
      array[1] = "two"
      array[2] = "three"
    end.not_to change(array, :count)

    expect(array[0]).to eq ObjRuby::NSString("one")
    expect(array[1]).to eq ObjRuby::NSString("two")
    expect(array[2]).to eq ObjRuby::NSString("three")
  end

  it "can remove objects" do
    array = described_class.arrayWithArray([1, 2, 3])

    expect do
      array.removeObject(2)
    end.to change(array, :count).by(-1)

    expect(array[0]).to eq ObjRuby::NSNumber(1)
    expect(array[1]).to eq ObjRuby::NSNumber(3)
  end
end
