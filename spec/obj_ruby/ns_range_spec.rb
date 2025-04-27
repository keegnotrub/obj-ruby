# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSRange do
  it "can create an instance" do
    range1 = described_class.new(0, 5)
    range2 = ObjRuby::NSMakeRange(5, 10)

    expect(range1).to be_a described_class
    expect(range1.location).to eq 0
    expect(range1.length).to eq 5

    expect(range2).to be_a described_class
    expect(range2.location).to eq 5
    expect(range2.length).to eq 10
  end

  it "can detect a numbe in range" do
    range = ObjRuby::NSMakeRange(0, 5)

    expect(ObjRuby::NSLocationInRange(-1, range)).to be false
    expect(ObjRuby::NSLocationInRange(0, range)).to be true
    expect(ObjRuby::NSLocationInRange(2, range)).to be true
    expect(ObjRuby::NSLocationInRange(4, range)).to be true
    expect(ObjRuby::NSLocationInRange(5, range)).to be false
  end
end
