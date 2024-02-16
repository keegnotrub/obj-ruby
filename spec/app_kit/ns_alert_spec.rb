require "spec_helper"
require "obj_ruby/app_kit"

RSpec.describe ObjRuby::NSAlert do
  it "can create an instance" do
    alert = described_class.new

    expect(alert).not_to be_nil
    expect(alert).to be_a described_class
  end
end
