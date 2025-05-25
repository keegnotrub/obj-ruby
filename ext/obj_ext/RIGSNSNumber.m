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
    case _C_FLT:
    case _C_LNG:
      return LONG2NUM([rcv longValue]);
    case _C_UINT:
      return UINT2NUM([rcv unsignedIntValue]);
    default:
      return INT2FIX([rcv intValue]);
    }
  }
}

VALUE
rb_objc_number_to_f(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return DBL2NUM([rcv doubleValue]);
  }
}

VALUE
rb_objc_number_to_rb(NSNumber *val)
{
  const char *type = [val objCType];

  if (*type == _C_CHR) {
    if ([val charValue] == YES) return Qtrue;
    if ([val charValue] == NO) return Qfalse;
  }
  
  switch (*type) {
  case _C_ULNG_LNG:
    return ULL2NUM([val unsignedLongLongValue]);
  case _C_LNG_LNG:
    return LL2NUM([val longLongValue]);
  case _C_DBL:
  case _C_FLT:
    return DBL2NUM([val doubleValue]);
  case _C_ULNG:
    return ULONG2NUM([val unsignedLongValue]);
  case _C_LNG:
    return LONG2NUM([val longValue]);
  case _C_UINT:
    return UINT2NUM([val unsignedIntValue]);
  default:
    return INT2FIX([val intValue]);
  }
}

NSNumber*
rb_objc_number_from_rb(VALUE rb_val)
{
  switch (TYPE(rb_val)){
  case T_BIGNUM:
    return [NSNumber numberWithLongLong:rb_big2ll(rb_val)];
  case T_FIXNUM:
    return [NSNumber numberWithLong:FIX2LONG(rb_val)];
  case T_FLOAT:
    return [NSNumber numberWithDouble:RFLOAT_VALUE(rb_val)];
  case T_FALSE:
  case T_TRUE:
    return [NSNumber numberWithBool:rb_val == Qtrue];
  default:
    rb_raise(rb_eTypeError, "type 0x%02x not valid NSNumber value", TYPE(rb_val));
    break;
  }
}
