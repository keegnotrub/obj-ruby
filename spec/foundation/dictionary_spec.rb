require "spec_helper"
require "obj_ruby/foundation"

describe ObjRuby::NSDictionary do
  it "can create an instance" do
    date = described_class.new

    expect(date).not_to be_nil
    expect(date).to be_a described_class
  end

  it "can call instance methods" do
    dict = described_class.dictionaryWithObject_forKey("value", "key")

    expect(dict.objectForKey(:key)).to eq "value"
    expect(dict.objectForKey(:not_key)).to be_nil
  end

  it "can receive a Ruby hash" do
    dict = described_class.dictionaryWithDictionary(key1: "value1", key2: "value2")

    expect(dict.count).to eq 2
    expect(dict.objectForKey(:key1)).to eq "value1"
    expect(dict.objectForKey(:key2)).to eq "value2"
    expect(dict.objectForKey(:not_key)).to be_nil
  end

  xit "can receive a variable argument list" do
    dict = described_class.dictionaryWithDictionary(key1: "value1", key2: "value2")
    manual_dict = described_class.dictionaryWithObjectsAndKeys("value1", :key1, "value2", :key2, nil)

    expect(dict.isEqualToDictionary(manual_dict)).to be true
  end

  it "can be transformed into a Ruby hash" do
    dict = described_class.dictionaryWithDictionary(key: "value")

    hash = dict.to_h

    expect(hash).to be_a Hash
    expect(hash.include?("key")).to be true
    expect(hash["key"]).to eq "value"
  end
end
