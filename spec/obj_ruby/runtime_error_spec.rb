# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::RuntimeError do
  it "is raised when we have an uncaught Objective-C exception" do
    expect do
      obj = ObjRuby::NSObject.new
      obj.performSelector(:notASelector)
    end.to raise_error(described_class)
  end
end
