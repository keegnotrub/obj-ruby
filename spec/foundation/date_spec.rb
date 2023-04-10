require "spec_helper"

ObjRuby.import("NSDate")

describe NSDate do
  it "can create an instance" do
    expect(described_class.new).not_to be_nil
  end

  it "can call instance methods" do
    date = described_class.new
    other_date = date.addTimeInterval(1000)

    earlier_date = date.earlierDate(other_date)

    expect(earlier_date).to eq date
  end
end
