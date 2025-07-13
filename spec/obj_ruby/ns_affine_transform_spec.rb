# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSAffineTransform do
  it "can create an instance" do
    transform = described_class.new

    expect(transform).not_to be_nil
    expect(transform).to be_a described_class
  end

  it "can get a struct transform" do
    transform = described_class.new

    expect(transform.transformStruct).not_to be_nil
    expect(transform.transformStruct).to be_a ObjRuby::NSAffineTransformStruct
  end

  it "can set a struct transform" do
    transform = described_class.new
    struct = ObjRuby::NSAffineTransformStruct.new(1.0, 1.0, 1.0, 1.0, 1.0, 1.0)

    transform.transformStruct = struct

    expect(transform.transformStruct).not_to be_nil
    expect(transform.transformStruct).to eq(struct)
  end
end
