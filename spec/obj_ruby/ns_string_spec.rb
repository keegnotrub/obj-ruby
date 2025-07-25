# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSString do
  it "can create an instance" do
    string = described_class.new

    expect(string).not_to be_nil
    expect(string).to be_a described_class
  end

  it "can receive variable length arguments" do
    string = described_class.stringWithFormat("one %d three %@ %d", 2, "four", 5)

    expect(string.length).to eq 18
    expect(string).to eq ObjRuby::NSString("one 2 three four 5")
  end

  it "can reeceive a C string" do
    string = described_class.stringWithCString("hello")

    expect(string.length).to eq 5
    expect(string).to eq ObjRuby::NSString("hello")
  end

  it "can receive a Ruby string" do
    string = described_class.stringWithString("hello")

    expect(string.length).to eq 5
    expect(string).to eq ObjRuby::NSString("hello")
  end

  it "can be transformed to a Ruby string" do
    string = described_class.stringWithString("hello")

    result = string.to_s

    expect(result).to be_a String
    expect(result.size).to eq 5
    expect(result).to eq "hello"
  end
end
