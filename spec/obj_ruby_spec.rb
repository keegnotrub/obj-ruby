require "spec_helper"

describe ObjRuby do
  describe "#import" do
    it "loads the Objective-C class into Ruby's namespace" do
      described_class.import("NSObject")

      expect(described_class.const_defined?(:NSObject)).to be true
    end
  end

  describe "#require_frameowrk" do
    it "loads all Objective-C classes of a given framework into Ruby's namespace" do
      described_class.require_framework("Foundation")

      expect(described_class.const_defined?(ObjRuby::FOUNDATION.sample)).to be true
    end

    it "loads all dependent Objective-C classes from a dependent framework into Ruby's namespace" do
      described_class.require_framework("AppKit")

      expect(described_class.const_defined?(ObjRuby::APP_KIT.sample)).to be true
      expect(described_class.const_defined?(ObjRuby::FOUNDATION.sample)).to be true
    end
  end
end
