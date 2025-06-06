# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSNull do
  it "can create an instance" do
    null = described_class.new

    expect(null).to be_a described_class
    expect(null).not_to be_nil
  end

  it "can create the singleton" do
    null = described_class.null

    expect(null).to be_a described_class
    expect(null).not_to be_nil
  end

  it "is equal to the singleton for any instance" do
    expect(described_class.new).to eq(described_class.null)
  end
end
