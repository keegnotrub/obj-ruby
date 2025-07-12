# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSProcessInfo do
  it "can create an instance" do
    info = described_class.new

    expect(info).not_to be_nil
    expect(info).to be_a described_class
  end

  it "can retreive operating system versions" do
    info = described_class.processInfo

    version = info.operatingSystemVersion

    pp version

    expect(version).not_to be_nil
    expect(version).to be_a ObjRuby::NSOperatingSystemVersion
  end

  it "can compare operating system versions" do
    info = described_class.processInfo
    version = ObjRuby::NSOperatingSystemVersion.new(10, 0, 0)

    expect(info.isOperatingSystemAtLeastVersion(version)).to be true
  end
end
