# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby do
  describe ".import" do
    it "returns false for already loaded frameworks" do
      # spec_helper loads these
      expect(described_class.import("Foundation")).to be false
      expect(described_class.import("CoreData")).to be false
      expect(described_class.import("AppKit")).to be false
    end

    it "returns true for frameworks not yet loaded" do
      expect(described_class.import("WebKit")).to be true
    end

    it "raises an error for unknown frameworks" do
      expect do
        described_class.import("NotAFramework")
      end.to raise_error(LoadError)
    end

    it "defines Foundation Objective-C constants" do
      expect(described_class.const_get(:NSNotFound)).to eq (2**63) - 1
      expect(described_class.const_get(:NSOrderedSame)).to eq 0
      expect(described_class.const_get(:NSASCIIStringEncoding)).to eq 1
      expect(described_class.const_get(:NSWeekDayNameArray)).to eq "NSWeekDayNameArray"
      expect(described_class.const_get(:NSZombieEnabled)).to be false
    end

    it "defines CoreData Objective-C constants" do
      expect(described_class.const_get(:NSAffectedObjectsErrorKey)).to eq "NSAffectedObjectsErrorKey"
    end

    it "defines AppKit Objective-C constants" do
      expect(described_class.const_get(:NSOKButton)).to eq 1
      expect(described_class.const_get(:NSCancelButton)).to eq 0
    end
  end
end
