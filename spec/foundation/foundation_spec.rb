require "spec_helper"

require "foundation"

describe FoundationClasses do
  it "loads its Objective-C classes into Ruby's namespace" do
    expect(Object.const_defined?(described_class.sample)).to eq true
  end
end

