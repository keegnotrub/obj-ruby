# frozen_string_literal: true

require "spec_helper"

RSpec.describe ObjRuby::NSObject do
  it "can create an instance" do
    obj = described_class.new

    expect(obj).to be_a described_class
    expect(obj).not_to be_nil
  end

  it "uses description for to_s" do
    obj = described_class.new

    expect(obj.to_s).to eq(obj.description.to_s)
  end

  it "uses debugDescription for inspect" do
    obj = described_class.new

    expect(obj.inspect).to eq(obj.debugDescription.to_s)
  end

  it "does not subclass Object" do
    obj = described_class.new

    expect(obj).not_to be_a Object
  end

  it "doesn't have a superclass" do
    expect(described_class.superclass).to be_nil
  end

  describe "subclasses" do
    it "can be subclassed" do
      obj = TestMyObject.new

      expect(obj).to be_a described_class
      expect(obj).to be_an_instance_of TestMyObject
      expect(obj).not_to be_nil
    end

    it "can call subclass methods without args from the Objective-C runtime" do
      obj = TestMyObject.new

      result = obj.performSelector(:myObjcMethod)

      expect(result).to be_a ObjRuby::NSString
      expect(result).to eq "expected myObjcMethod return"
      expect(obj.respondsToSelector("myObjcMethod")).to be(true)
    end

    it "can call subclass methods with one arg from the Objective-C runtime" do
      obj = TestMyObject.new

      result = obj.performSelector_withObject("myObjcMethodWithArg:", "1")

      expect(result).to be_a ObjRuby::NSString
      expect(result).to eq "expected myObjcMethodWithArg(1) return"
      expect(obj.respondsToSelector("myObjcMethodWithArg")).to be(false)
      expect(obj.respondsToSelector("myObjcMethodWithArg:")).to be(true)
    end

    it "can call subclass methods with two args from the Objective-C runtime" do
      obj = TestMyObject.new

      result = obj.performSelector_withObject_withObject("myObjcMethodWithArg1:andArg2:", "1", "2")

      expect(result).to be_a ObjRuby::NSString
      expect(result).to eq "expected myObjcMethodWithArg1_andArg2(1, 2) return"
      expect(obj.respondsToSelector("myObjcMethodWithArg1_andArg2")).to be(false)
      expect(obj.respondsToSelector("myObjcMethodWithArg1_andArg2:")).to be(false)
      expect(obj.respondsToSelector("myObjcMethodWithArg1:andArg2:")).to be(true)
    end

    it "doesn't expose non-conforming ruby methods to the Objective-C runtime" do
      obj = TestMyObject.new

      expect(obj.respondsToSelector("my_method")).to be(false)
      expect(obj.respondsToSelector("my_method:")).to be(false)
      expect(obj.respondsToSelector("my:method:")).to be(false)
      expect(obj.respondsToSelector("my_argmethod")).to be(false)
      expect(obj.respondsToSelector("my_argmethod:")).to be(false)
      expect(obj.respondsToSelector("my:argmethod:")).to be(false)
    end
  end
end
