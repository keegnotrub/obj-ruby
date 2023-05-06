require "spec_helper"

ObjRuby.import("NSNumber")

describe NSNumber do
  it "can create an instance" do
    number = described_class.numberWithBool(true)
    
    expect(number).not_to be_nil
    expect(number).to be_a NSNumber
  end

  it "can call instance methods" do
    number = described_class.numberWithLong(3)

    expect(number.intValue).to eq 3
    expect(number.doubleValue).to eq 3.0
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
