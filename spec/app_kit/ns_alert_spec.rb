require "spec_helper"

ObjRuby.import("NSAlert")

describe NSAlert do
  it "can create an instance" do
    array = described_class.new
    
    expect(array).not_to be_nil
    expect(array).to be_a NSAlert
  end
end
