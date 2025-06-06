# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSMutableDictionary do
  it "can create an instance" do
    dict = described_class.new

    expect(dict).not_to be_nil
    expect(dict).to be_a described_class
  end

  it "can add entries" do
    dict = described_class.new

    expect do
      dict.setObject_forKey(1, "one")
      dict.setObject_forKey(2, "two")
      dict.setObject_forKey(3, "three")
    end.to change(dict, :count).by(3)

    expect(dict["one"]).to eq(1)
    expect(dict["two"]).to eq(2)
    expect(dict["three"]).to eq(3)
  end

  it "can add entries by keyed subscript" do
    dict = described_class.new

    expect do
      dict["one"] = 1
      dict["two"] = 2
      dict["three"] = 3
    end.to change(dict, :count).by(3)

    expect(dict["one"]).to eq(1)
    expect(dict["two"]).to eq(2)
    expect(dict["three"]).to eq(3)
  end

  it "can replace entries" do
    dict = described_class.dictionaryWithDictionary(key1: "value1", key2: "value2")

    expect do
      dict.setObject_forKey("value1!", :key1)
      dict.setObject_forKey("value2!", :key2)
    end.not_to change(dict, :count)

    expect(dict[:key1]).to eq("value1!")
    expect(dict[:key2]).to eq("value2!")
  end

  it "can replace entries by keyed subscript" do
    dict = described_class.dictionaryWithDictionary(key1: "value1", key2: "value2")

    expect do
      dict[:key1] = "value1!"
      dict[:key2] = "value2!"
    end.not_to change(dict, :count)

    expect(dict[:key1]).to eq("value1!")
    expect(dict[:key2]).to eq("value2!")
  end

  it "can remove entries" do
    dict = described_class.dictionaryWithDictionary(key1: "value1", key2: "value2")

    expect do
      dict.removeObjectForKey(:key1)
    end.to change(dict, :count).by(-1)

    expect(dict[:key1]).to be_nil
    expect(dict[:key2]).to eq("value2")
  end
end
