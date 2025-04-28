# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby do
  it "defines Foundation Objective-C constants" do
    expect(described_class.const_get(:NSNotFound)).to eq (2**63) - 1
    expect(described_class.const_get(:NSOrderedSame)).to eq 0
    expect(described_class.const_get(:NSASCIIStringEncoding)).to eq 1
    expect(described_class.const_get(:NSWeekDayNameArray)).to eq "NSWeekDayNameArray"
    expect(described_class.const_get(:NSZombieEnabled)).to be false
  end

  it "defines AppKit Objective-C constants" do
    expect(described_class.const_get(:NSOKButton)).to eq 1
    expect(described_class.const_get(:NSCancelButton)).to eq 0
  end

  it "defines CoreData Objective-C constants" do
    expect(described_class.const_get(:NSAffectedObjectsErrorKey)).to eq "NSAffectedObjectsErrorKey"
  end
end
