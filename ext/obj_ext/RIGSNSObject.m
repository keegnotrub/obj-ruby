/* RIGSNSObject.m - Some additional code to properly wrap the
   NSObject class in Ruby

   Written by: Ryan Krug <keegnotrub@icloud.com>
   Date: May 2025

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "RIGSNSObject.h"
#import "RIGSCore.h"

VALUE
rb_objc_object_compare(VALUE rb_self, VALUE rb_val)
{
  @autoreleasepool {
    id rcv;
    id objc_val;

    if (NIL_P(rb_val)) {
      return Qnil;
    }
    
    if (rb_self == rb_val) {
      return INT2FIX(0);
    }

    if (rb_iv_get(CLASS_OF(rb_val), "@objc_class") == Qnil) {
      return Qnil;
    }

    Data_Get_Struct(rb_self, void, rcv);
    Data_Get_Struct(rb_val, void, objc_val);

    if (rcv == objc_val) {
      return INT2FIX(0);
    }

    if ([rcv isEqual:objc_val]) {
      return INT2FIX(0);
    }

    return Qnil;
  }
}

VALUE
rb_objc_object_equal(VALUE rb_self, VALUE rb_val)
{
  @autoreleasepool {
    id rcv;
    id objc_val;

    if (NIL_P(rb_val)) {
      return Qfalse;
    }
    
    if (rb_self == rb_val) {
      return Qtrue;
    }

    if (rb_iv_get(CLASS_OF(rb_val), "@objc_class") == Qnil) {
      return Qfalse;
    }

    Data_Get_Struct(rb_self, void, rcv);
    Data_Get_Struct(rb_val, void, objc_val);

    if (rcv == objc_val) {
      return Qtrue;
    }

    if ([rcv isEqual:objc_val]) {
      return Qtrue;
    }

    return Qfalse;
  }
}

VALUE
rb_objc_object_to_s(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return rb_str_new_cstr([[rcv description] UTF8String]);
  }
}

VALUE
rb_objc_object_inspect(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return rb_str_new_cstr([[rcv debugDescription] UTF8String]);
  }
}

VALUE
rb_objc_object_pretty_print(VALUE rb_self, VALUE rb_pp)
{
  @autoreleasepool {
    id rcv;
    VALUE text;

    Data_Get_Struct(rb_self, void, rcv);

    text = rb_str_new_cstr([[rcv debugDescription] UTF8String]);

    return rb_funcall(rb_pp, rb_intern("text"), 1, text);
  }
}

VALUE
rb_objc_object_is_kind_of(VALUE rb_self, VALUE rb_class)
{
  @autoreleasepool {
    id rcv;
    Class objc_class;
    VALUE iv;

    iv = rb_iv_get(rb_class, "@objc_class");
    if (iv == Qnil) {
      return Qfalse;
    }

    objc_class = (Class)NUM2LL(iv);
    Data_Get_Struct(rb_self, void, rcv);

    if ([[rcv classForCoder] isSubclassOfClass:objc_class]) {
      return Qtrue;
    }

    return Qfalse;
  }
}

VALUE
rb_objc_object_is_instance_of(VALUE rb_self, VALUE rb_class)
{
  @autoreleasepool {
    id rcv;
    Class objc_class;
    VALUE iv;

    iv = rb_iv_get(rb_class, "@objc_class");
    if (iv == Qnil) {
      return Qfalse;
    }

    objc_class = (Class)NUM2LL(iv);
    Data_Get_Struct(rb_self, void, rcv);

    if ([rcv classForCoder] == objc_class) {
      return Qtrue;
    }

    return Qfalse;
  }
}

VALUE
rb_objc_object_inherited(VALUE rb_class, VALUE rb_subclass)
{
  @autoreleasepool {
    const char *name;

    name = rb_class2name(rb_subclass);

    if (strncmp(name, "ObjRuby::", 9) == 0) {
      return Qnil;
    }

    rb_objc_register_class_from_rb(rb_subclass);

    return Qnil;
  }
}

VALUE
rb_objc_object_method_added(VALUE rb_class, VALUE rb_method)
{
  @autoreleasepool {
    const char *name;
  
    name = rb_class2name(rb_class);

    if (strncmp(name, "ObjRuby::", 9) == 0) {
      return Qnil;
    }
  
    return rb_objc_register_instance_method_from_rb(rb_class, rb_method);
  }
}
