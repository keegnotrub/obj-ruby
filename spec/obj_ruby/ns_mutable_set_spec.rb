# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSMutableSet do
  it "can create an instance" do
    set = described_class.new

    expect(set).not_to be_nil
    expect(set).to be_a described_class
  end

  it "can add objects" do
    set = described_class.new

    expect do
      set << "one"
      set << "one"
      set << "two"
    end.to change(set, :count).by(2)
  end
end
