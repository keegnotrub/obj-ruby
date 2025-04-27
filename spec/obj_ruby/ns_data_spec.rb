# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSData do
  it "can create an instance" do
    data = described_class.new

    expect(data).not_to be_nil
    expect(data).to be_a described_class
  end

  it "sets an error on failure" do
    error_ptr = ObjRuby::Pointer.new(:object)

    result = described_class.dataWithContentsOfFile_options_error("not-a-path", 0, error_ptr)

    error = error_ptr[0]

    expect(result).to be_nil
    expect(error).not_to be_nil
    expect(error).to be_a ObjRuby::NSError
  end
end
