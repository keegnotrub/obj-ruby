# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSFetchRequest do
  it "can create an instance" do
    request = described_class.new

    expect(request).to be_a described_class
  end
end
