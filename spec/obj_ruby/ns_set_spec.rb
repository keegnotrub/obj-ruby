# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSSet do
  it "can create an instance" do
    set = described_class.new

    expect(set).not_to be_nil
    expect(set).to be_a described_class
  end

  it "can receive a Ruby set" do
    set = described_class.setWithSet(Set[1, 2, 3])

    expect(set.count).to eq 3
    expect(set.containsObject(1)).to be true
    expect(set.containsObject(2)).to be true
    expect(set.containsObject(3)).to be true
    expect(set.containsObject(4)).to be false
  end

  it "can receive a Ruby array" do
    set = described_class.setWithArray([1, 2, 2, 3])

    expect(set.count).to eq 3
    expect(set.containsObject(1)).to be true
    expect(set.containsObject(2)).to be true
    expect(set.containsObject(3)).to be true
    expect(set.containsObject(4)).to be false
  end

  it "can receive a variable argument list" do
    set = described_class.setWithObjects(1, 2, 2, 3, nil)

    expect(set.count).to eq 3
    expect(set.containsObject(1)).to be true
    expect(set.containsObject(2)).to be true
    expect(set.containsObject(3)).to be true
    expect(set.containsObject(4)).to be false
  end
end
