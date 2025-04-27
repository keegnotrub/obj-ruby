# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSView do
  it "can create an instance" do
    view = described_class.new

    expect(view).to be_a described_class
  end

  it "can call a method that returns a struct" do
    view = described_class.new

    expect(view.bounds).to be_a ObjRuby::NSRect
  end
end
