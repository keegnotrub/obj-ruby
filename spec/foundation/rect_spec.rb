require "spec_helper"
require "obj_ruby/foundation"

describe ObjRuby::NSRect do
  it "can create an instance" do
    rect = ObjRuby::NSMakeRect(1,2,3,4)

    expect(rect).not_to be_nil
    expect(rect).to be_a described_class
  end
end
