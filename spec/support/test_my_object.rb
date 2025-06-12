# frozen_string_literal: true

class TestMyObject < ObjRuby::NSObject
  def myObjcMethod
    "expected myObjcMethod return"
  end

  def myDangerousObjcMethod
    raise "expected myDangerousObjcMethod message"
  end

  def myObjcMethodWithArg(arg)
    "expected myObjcMethodWithArg(#{arg}) return"
  end

  def myObjcMethodWithArg1_andArg2(arg1, arg2)
    "expected myObjcMethodWithArg1_andArg2(#{arg1}, #{arg2}) return"
  end

  def my_method
    "expected my_method return"
  end

  def my_argmethod(arg)
    "expected my_argmethod(#{arg}) return"
  end
end
