require "spec_helper"
require "obj_ruby/app_kit"

describe ObjRuby::NSAlert do
  it "can create an instance" do
    array = described_class.new

    expect(array).not_to be_nil
    expect(array).to be_a described_class
  end
end
