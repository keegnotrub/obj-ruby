require "spec_helper"

ObjRuby.import("NSDate")

describe ObjRuby::NSDate do
  it "can create an instance" do
    date = described_class.new

    expect(date).not_to be_nil
    expect(date).to be_a described_class
  end

  it "can call instance methods" do
    date = described_class.dateWithTimeIntervalSince1970(42424242)
    other_date = date.addTimeInterval(1000)
    earlier_date = date.earlierDate(other_date)

    expect(date.timeIntervalSince1970).to eq 42424242
    expect(other_date.timeIntervalSince1970).to eq 42424242 + 1000
    expect(earlier_date).to eq date
  end
end
