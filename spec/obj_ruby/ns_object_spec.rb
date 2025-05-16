# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSObject do
  it "uses description for to_s" do
    obj = described_class.new

    expect(obj.to_s).to eq(obj.description.to_s)
  end

  it "uses debugDescription for inspect" do
    obj = described_class.new

    expect(obj.inspect).to eq(obj.debugDescription.to_s)
  end

  it "doesn't have a superclass" do
    expect(described_class.superclass).to be_nil
  end
end
