# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSSize do
  it "can create an instance" do
    size = described_class.new(100, 200)

    expect(size).to be_a described_class
    expect(size.width).to eq 100
    expect(size.height).to eq 200
  end

  it "can create an instance with the function helper" do
    size = ObjRuby::NSMakeSize(10, 20)

    expect(size).to be_a described_class
    expect(size.width).to eq 10
    expect(size.height).to eq 20
  end
end
