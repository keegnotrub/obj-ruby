require "spec_helper"
require "obj_ruby/foundation"

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

  it "can receive a Ruby time" do
    time = Time.new

    date = described_class.dateWithTimeInterval_sinceDate(0, time)

    expect(date.timeIntervalSince1970).to eq time.to_f
    expect(date).to eq time
  end

  it "can be transformed into a Ruby time" do
    date = described_class.new

    result = date.to_time

    expect(result).to be_a Time
    expect(result.to_f).to eq date.timeIntervalSince1970
  end
end
