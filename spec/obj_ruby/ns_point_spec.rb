# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSPoint do
  it "can create an instance" do
    point1 = described_class.new(1, 2)
    point2 = ObjRuby::NSMakePoint(3, 4)

    expect(point1).to be_a described_class
    expect(point1.x).to eq 1
    expect(point1.y).to eq 2

    expect(point2).to be_a described_class
    expect(point2.x).to eq 3
    expect(point2.y).to eq 4
  end

  it "can be compared to an NSPoint constant" do
    expect(ObjRuby::NSZeroPoint).to eq described_class.new(0, 0)
  end

  it "can be compared to another NSPoint" do
    point1 = ObjRuby::NSMakePoint(100, 200)
    point2 = described_class.new(100, 200)
    point3 = ObjRuby::NSMakePoint(50, 100)

    expect(ObjRuby::NSEqualPoints(point1, point2)).to be true
    expect(ObjRuby::NSEqualPoints(point1, point3)).to be false
  end

  it "can be translated from a string" do
    point = ObjRuby::NSPointFromString("{1, 2}")

    expect(point).to be_a described_class
    expect(point.x).to eq 1
    expect(point.y).to eq 2
  end

  it "can be translated to a string" do
    point = described_class.new(1, 2)
    result = ObjRuby::NSStringFromPoint(point)

    expect(result).to be_a ObjRuby::NSString
    expect(result).to eq ObjRuby::NSString("{1, 2}")
  end
end
