require "spec_helper"

require "app_kit"

describe AppKitClasses do
  it "preloads Foundation classes into Ruby's namespace" do
    expect(Object.const_defined?("FoundationClasses")).to eq true
    expect(Object.const_defined?(FoundationClasses.sample)).to eq true
  end
  
  it "loads its Objective-C classes into Ruby's namespace" do
    expect(Object.const_defined?(described_class.sample)).to eq true
  end
end
