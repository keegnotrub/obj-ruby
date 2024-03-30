require "spec_helper"
require "obj_ruby/foundation"

RSpec.describe ObjRuby::NSObject do
  it "can set ib_outets that act as attr_accessor" do
    described_class.ib_outlet :myThing, :otherThing

    obj = described_class.new

    obj.myThing = "a"
    obj.setOtherThing("b")

    expect(obj.myThing).to eq("a")
    expect(obj.otherThing).to eq("b")
  end

  it "uses description for to_s" do
    obj = described_class.new

    expect(obj.to_s).to eq(obj.description.to_s)
  end

  it "uses debugDescription for inspect" do
    obj = described_class.new

    expect(obj.inspect).to eq(obj.debugDescription.to_s)
  end
end
