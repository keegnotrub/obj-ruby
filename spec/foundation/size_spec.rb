require "spec_helper"
require "obj_ruby/foundation"

describe ObjRuby::NSSize do
  it "can create an instance" do
    size1 = described_class.new(100, 200)
    size2 = ObjRuby::NSMakeSize(10, 20)

    expect(size1).to be_a described_class
    expect(size1.width).to eq 100
    expect(size1.height).to eq 200

    expect(size2).to be_a described_class
    expect(size2.width).to eq 10
    expect(size2.height).to eq 20
  end
end
