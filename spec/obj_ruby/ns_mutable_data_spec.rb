# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSMutableData do
  it "can create an instance" do
    data = described_class.new

    expect(data).not_to be_nil
    expect(data).to be_a described_class
  end

  it "can append data" do
    data = described_class.new
    hello = ObjRuby::NSString.stringWithString("hello")

    expect do
      data << hello.dataUsingEncoding(ObjRuby::NSUTF8StringEncoding)
    end.to change(data, :length).by(hello.length)
  end
end
