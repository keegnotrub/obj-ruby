# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSNumber do
  it "can create an instance" do
    number = described_class.numberWithBool(true)

    expect(number).not_to be_nil
    expect(number).to be_a described_class
  end

  it "can call instance methods" do
    number = described_class.numberWithLong(3)

    expect(number.intValue).to eq 3
    expect(number.doubleValue).to eq 3.0
  end

  it "can be compared to a Ruby numeric or bool" do
    number = described_class.numberWithInt(3)

    expect(number.isEqualToNumber(3)).to be true
    expect(number.isEqualToNumber(4)).to be false
    expect(number.isEqualToNumber(3.1)).to be false
    expect(number.isEqualToNumber(false)).to be false
    expect(number.isEqualToNumber(true)).to be false
  end

  it "can be transformed into a Ruby integer" do
    number = described_class.numberWithInt(3)

    result = number.to_i

    expect(result).to be_a Integer
    expect(result).to eq 3
  end

  it "can be transformed into a Ruby float" do
    number = described_class.numberWithFloat(3.0)

    result = number.to_f

    expect(result).to be_a Float
    expect(result).to eq 3.0
  end
end
