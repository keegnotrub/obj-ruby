require "spec_helper"

ObjRuby.import("NSDictionary")

describe NSDictionary do
  it "can create an instance" do
    date = described_class.new
    
    expect(date).not_to be_nil
    expect(date).to be_a NSDictionary
  end

  it "can call instance methods" do
    dict = described_class.dictionaryWithObject_forKey("value", "key")

    expect(dict.objectForKey("key")).to eq "value"
    expect(dict.objectForKey("not_key")).to be_nil
  end
end
