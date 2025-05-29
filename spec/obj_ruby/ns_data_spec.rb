# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSData do
  it "can create an instance" do
    data = described_class.new

    expect(data).not_to be_nil
    expect(data).to be_a described_class
  end
end
