# frozen_string_literal: true

require "spec_helper"

describe ObjRuby::NSLayoutManager do
  it "can create an instance" do
    label = described_class.new

    expect(label).not_to be_nil
    expect(label).to be_a described_class
  end

  it "can call a method that returns a struct" do
    layout = described_class.new

    label = ObjRuby::NSTextView.new
    label.textStorage.setAttributedString(
      ObjRuby::NSAttributedString.alloc.initWithString("Hello")
    )

    container = label.textContainer
    layout.addTextContainer(container)
    layout.ensureLayoutForTextContainer(container)

    rect = layout.usedRectForTextContainer(container)

    expect(rect).not_to be_nil
    expect(rect).to be_a ObjRuby::NSRect
  end
end
