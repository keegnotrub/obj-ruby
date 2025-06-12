/* RIGSNSNumber.m - Some additional code to properly wrap the
   NSNumber class in Ruby and provide some convenient new methods

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

#import "RIGSNSNumber.h"
#import "RIGSCore.h"

VALUE
rb_objc_number_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    NSNumber *objc_num;
    VALUE rb_num;
    const char idType[] = {_C_ID,'\0'};

    objc_num = rb_objc_number_from_rb(rb_val);

    rb_objc_convert_to_rb((void *)&objc_num, 0, idType, &rb_num);

    return rb_num;
  }  
}


VALUE
rb_objc_number_compare(VALUE rb_self, VALUE rb_val)
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
    if (![objc_class isSubclassOfClass:[NSNumber class]]) {
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
rb_objc_number_to_i(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;
    const char *type;

    Data_Get_Struct(rb_self, void, rcv);

    type = [rcv objCType];

    switch (*type) {
    case _C_ULNG_LNG:
      return ULL2NUM([rcv unsignedLongLongValue]);
    case _C_LNG_LNG:
    case _C_DBL:
      return LL2NUM([rcv longLongValue]);
    case _C_ULNG:
      return ULONG2NUM([rcv unsignedLongValue]);
    case _C_UINT:
      return UINT2NUM([rcv unsignedIntValue]);
    default:
      return INT2FIX([rcv longValue]);
    }
  }
}

VALUE
rb_objc_number_to_f(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return rb_float_new([rcv doubleValue]);
  }
}

NSNumber*
rb_objc_number_from_rb(VALUE rb_val)
{
  switch (TYPE(rb_val)){
  case T_BIGNUM:
    return [NSNumber numberWithLongLong:rb_big2ll(rb_val)];
  case T_FIXNUM:
    return [NSNumber numberWithLong:rb_fix2long(rb_val)];
  case T_FLOAT:
    return [NSNumber numberWithDouble:rb_float_value(rb_val)];
  case T_FALSE:
  case T_TRUE:
    return [NSNumber numberWithBool:rb_val == Qtrue];
  default:
    rb_raise(rb_eTypeError, "type 0x%02x not valid NSNumber value", TYPE(rb_val));
    break;
  }
}
