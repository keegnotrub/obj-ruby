require "spec_helper"

RSpec.describe ObjRuby do
  it "loads CoreData Objective-C classes into Ruby's namespace" do
    expect(described_class.const_defined?(:NSFetchRequest)).to be true
  end

  it "loads CoreData Objective-C constants into Ruby's namespace" do
    expect(described_class.const_get(:NSAffectedObjectsErrorKey)).to eq "NSAffectedObjectsErrorKey"
  end
end
