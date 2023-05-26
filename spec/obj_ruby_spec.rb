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

      expect(described_class.const_defined?(:NSAffineTransform)).to be true
      expect(described_class.const_defined?(:NSAppleEventDescriptor)).to be true
      expect(described_class.const_defined?(:NSAppleEventManager)).to be true
      expect(described_class.const_defined?(:NSAppleScript)).to be true
    end

    it "loads Objective-C structs of a given framework into Ruby's namespace" do
      described_class.require_framework("Foundation")

      expect(described_class.const_defined?(:NSRange)).to be true
      expect(described_class.const_defined?(:NSPoint)).to be true
      expect(described_class.const_defined?(:NSSize)).to be true
      expect(described_class.const_defined?(:NSRect)).to be true
    end

    it "loads Objective-C enums of a given framework into Ruby's namespace" do
      described_class.require_framework("Foundation")

      expect(described_class.const_defined?(:NSNotFound)).to be true
      expect(described_class.const_defined?(:NSOrderedSame)).to be true
      expect(described_class.const_defined?(:NSASCIIStringEncoding)).to be true
    end
  end
end
