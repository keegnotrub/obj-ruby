require "spec_helper"

RSpec.describe ObjRuby::NSRect do
  it "can create an instance" do
    rect1 = ObjRuby::NSRect.new(ObjRuby::NSMakePoint(50, 100), ObjRuby::NSMakeSize(200, 300))
    rect2 = ObjRuby::NSMakeRect(100, 200, 50, 150)

    expect(rect1).to be_a described_class
    expect(rect1.origin).to eq ObjRuby::NSPoint.new(50, 100)
    expect(rect1.size).to eq ObjRuby::NSSize.new(200, 300)

    expect(rect2).to be_a described_class
    expect(rect2.origin).to eq ObjRuby::NSMakePoint(100, 200)
    expect(rect2.size).to eq ObjRuby::NSMakeSize(50, 150)
  end
end
