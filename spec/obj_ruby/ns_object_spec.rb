# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSObject do
  it "can create an instance" do
    obj = described_class.new

    expect(obj).to be_a described_class
    expect(obj).not_to be_nil
  end

  it "uses description for to_s" do
    obj = described_class.new

    expect(obj.to_s).to eq(obj.description.to_s)
  end

  it "uses debugDescription for inspect" do
    obj = described_class.new

    expect(obj.inspect).to eq(obj.debugDescription.to_s)
  end

  it "isn't an Object" do
    obj = described_class.new

    expect(obj.is_a?(Object)).to be(false)
  end

  it "doesn't have a superclass" do
    expect(described_class.superclass).to be_nil
  end
end
