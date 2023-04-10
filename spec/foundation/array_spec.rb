require "spec_helper"

ObjRuby.import("NSArray")

describe NSArray do
  it "can create an instance" do
    expect(described_class.new).not_to be_nil
  end
end
