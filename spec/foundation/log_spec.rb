require "spec_helper"
require "obj_ruby/foundation"

RSpec.describe "ObjRuby::NSLog" do
  it "can output to stderr" do
    expect {
      ObjRuby::NSLog("hello world")
    }.to output(/hello world/).to_stderr_from_any_process
  end

  it "can take variable arguments" do
    expect {
      ObjRuby::NSLog("one %d %@ %d", 2, "three", 4)
    }.to output(/one 2 three 4/).to_stderr_from_any_process
  end
end
