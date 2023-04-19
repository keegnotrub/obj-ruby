require "spec_helper"

ObjRuby.import("NSString")

describe NSString do
  it "can create an instance" do
    string = described_class.new

    expect(string).to be_a NSString
    expect(string).not_to be_nil
  end

  it "can call instance methods" do
    string = described_class.stringWithString("hello")

    expect(string.length).to eq 5
    expect(string).to eq "hello"
  end
end
