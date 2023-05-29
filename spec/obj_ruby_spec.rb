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

      expect(described_class.const_get(:NSRange).members).to eq [:location, :length]
      expect(described_class.const_get(:NSPoint).members).to eq [:x, :y]
      expect(described_class.const_get(:NSSize).members).to eq [:width, :height]
      expect(described_class.const_get(:NSRect).members).to eq [:origin, :size]
    end

    it "loads Objective-C enums of a given framework into Ruby's namespace" do
      described_class.require_framework("Foundation")

      expect(described_class.const_get(:NSNotFound)).to eq 2**63 - 1
      expect(described_class.const_get(:NSOrderedSame)).to eq 0
      expect(described_class.const_get(:NSASCIIStringEncoding)).to eq 1
    end

    it "loads Objective-C constants of a given framework into Ruby's namespace" do
      described_class.require_framework("Foundation")

      expect(described_class.const_get(:NSZeroPoint)).to eq ObjRuby::NSPoint.new(0, 0)
      expect(described_class.const_get(:NSWeekDayNameArray)).to eq "NSWeekDayNameArray"
      expect(described_class.const_get(:NSKeepAllocationStatistics)).to eq true
      expect(described_class.const_get(:NSZombieEnabled)).to eq false
    end
  end
end
