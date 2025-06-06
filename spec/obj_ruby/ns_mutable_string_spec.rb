# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSMutableString do
  it "can create an instance" do
    string = described_class.new

    expect(string).not_to be_nil
    expect(string).to be_a described_class
  end

  it "can append a string" do
    data = described_class.new
    hello = ObjRuby::NSString.stringWithString("hello")

    expect do
      data << hello
    end.to change(data, :length).by(hello.length)
  end
end
