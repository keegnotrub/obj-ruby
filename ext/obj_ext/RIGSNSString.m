/* RIGSNSString.m - Some additional code to properly wrap the
   NSString class in Ruby

   Written by: Ryan Krug <keegnotrub@icloud.com>
   Date: April 2023

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

#import "RIGSNSString.h"
#import "RIGSCore.h"

VALUE
rb_objc_string_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    NSString *objc_str;
    VALUE rb_str;
    const char idType[] = {_C_ID,'\0'};

    objc_str = rb_objc_string_from_rb(rb_val, Qtrue);

    rb_objc_convert_to_rb((void *)&objc_str, 0, idType, &rb_str);

    return rb_str;
  }  
}

VALUE
rb_objc_string_m_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    NSMutableString *objc_str;
    VALUE rb_str;
    const char idType[] = {_C_ID,'\0'};

    objc_str = rb_objc_string_from_rb(rb_val, Qfalse);

    rb_objc_convert_to_rb((void *)&objc_str, 0, idType, &rb_str);

    return rb_str;
  }  
}

VALUE
rb_objc_string_compare(VALUE rb_self, VALUE rb_val)
{
  @autoreleasepool {
    id rcv;
    id objc_val;
    Class objc_class;
    VALUE iv;

    if (NIL_P(rb_val)) {
      return Qnil;
    }

    if (rb_self == rb_val) {
      return INT2FIX(0);
    }

    iv = rb_iv_get(CLASS_OF(rb_val), "@objc_class");
    if (iv == Qnil) {
      return Qnil;
    }

    objc_class = (Class)NUM2LL(iv);
    if (![objc_class isSubclassOfClass:[NSString class]]) {
      return Qnil;
    }

    Data_Get_Struct(rb_self, void, rcv);
    Data_Get_Struct(rb_val, void, objc_val);

    if (rcv == objc_val) {
      return INT2FIX(0);
    }

    return INT2FIX([rcv compare:objc_val]);
  }
}

VALUE
rb_objc_string_to_s(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return rb_str_new_cstr([rcv UTF8String]);
  }
}

id
rb_objc_string_from_rb(VALUE rb_val, VALUE rb_frozen)
{
  VALUE rb_tmp;
  Class klass;

  klass = rb_frozen == Qtrue ? [NSString class] : [NSMutableString class];

  switch (TYPE(rb_val)) {
  case T_SYMBOL:
    rb_tmp = rb_sym_to_s(rb_val);
    return [klass stringWithUTF8String:rb_string_value_cstr(&rb_tmp)];
  case T_STRING:
    return [klass stringWithUTF8String:rb_string_value_cstr(&rb_val)];
  default:
    rb_raise(rb_eTypeError, "type 0x%02x not valid NSString value", TYPE(rb_val));
    break;
  }
}
