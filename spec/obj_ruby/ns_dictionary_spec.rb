# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSDictionary do
  it "can create an instance" do
    dict = described_class.new

    expect(dict).not_to be_nil
    expect(dict).to be_a described_class
  end

  it "can call instance methods" do
    dict = described_class.dictionaryWithObject_forKey("value", "key")

    expect(dict.objectForKey(:key)).to eq "value"
    expect(dict.objectForKey(:not_key)).to be_nil
  end

  it "can receive a Ruby hash" do
    dict = described_class.dictionaryWithDictionary(key1: "value1", key2: nil)

    expect(dict.count).to eq 2
    expect(dict.objectForKey(:key1)).to eq "value1"
    expect(dict.objectForKey(:key2)).to eq ObjRuby::NSNull.null
    expect(dict.objectForKey(:not_key)).to be_nil
  end

  it "can receive a variable argument list" do
    dict = described_class.dictionaryWithDictionary(key1: "value1", key2: "value2")
    manual_dict = described_class.dictionaryWithObjectsAndKeys("value1", :key1, "value2", :key2, nil)

    expect(dict.isEqualToDictionary(manual_dict)).to be true
  end

  it "can be transformed into a Ruby hash" do
    dict = described_class.dictionaryWithDictionary(key1: "value", key2: nil)

    hash = dict.to_h

    expect(hash).to be_a Hash
    expect(hash["key1"]).to eq "value"
    expect(hash["key2"]).to be_nil
  end
end
