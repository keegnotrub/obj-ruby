require "spec_helper"

RSpec.describe ObjRuby do
  it "loads AppKit Objective-C classes into Ruby's namespace" do
    expect(described_class.const_defined?(:NSView)).to be true
    expect(described_class.const_defined?(:NSApplication)).to be true
    expect(described_class.const_defined?(:NSAlert)).to be true
  end
end
