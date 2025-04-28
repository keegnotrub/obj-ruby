# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ObjRuby::NSLog" do
  it "can output to stderr" do
    expect do
      ObjRuby::NSLog("hello world")
    end.to output(/hello world/).to_stderr_from_any_process
  end

  it "can take variable arguments" do
    expect do
      ObjRuby::NSLog("one %d %@ %d", 2, "three", 4)
    end.to output(/one 2 three 4/).to_stderr_from_any_process
  end
end
