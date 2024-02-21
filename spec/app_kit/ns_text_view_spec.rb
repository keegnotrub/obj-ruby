require "spec_helper"
require "obj_ruby/app_kit"

RSpec.describe ObjRuby::NSTextView do
  it "can create an instance" do
    label = described_class.new

    expect(label).not_to be_nil
    expect(label).to be_a described_class
  end

  it "can call a method that returns a struct" do
    label = described_class.new

    text = ObjRuby::NSAttributedString.alloc.initWithString("Hello")
    label.textStorage.setAttributedString(text)

    label.layoutManager.ensureLayoutForTextContainer(label.textContainer)
    rect = label.layoutManager.usedRectForTextContainer(label.textContainer)

    expect(rect).not_to be_nil
    expect(rect).to be_a ObjRuby::NSRect
  end
end
