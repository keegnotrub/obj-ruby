/* RIGSNSNumber.m - Some additional code to properly wrap the
   NSNumber class in Ruby and provide some convenient new methods

   $Id$

   Copyright (C) 2023 thoughtbot, Inc.
   
   Written by:  Ryan Krug <ryan.krug@thoughtbot.com>
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

@implementation NSNumber ( RIGSNSNumber )

+ (id) numberWithRubyBignum: (VALUE) rb_bignum
{
  return [NSNumber numberWithLongLong:rb_big2ll(rb_bignum)];
}

+ (id) numberWithRubyFixnum: (VALUE) rb_fixnum
{
  return [NSNumber numberWithLong:FIX2LONG(rb_fixnum)];
}

+ (id) numberWithRubyFloat: (VALUE) rb_float
{
  return [NSNumber numberWithDouble:RFLOAT_VALUE(rb_float)];
}

+ (id) numberWithRubyBool: (VALUE) rb_bool
{
  return [NSNumber numberWithBool:rb_bool == Qtrue];
}

- (VALUE) getRubyObject
{
  const char *type = [self objCType];

  if (*type == _C_CHR) {
    if ([self charValue] == YES) return Qtrue;
    if ([self charValue] == NO) return Qfalse;
  }
  
  switch (*type) {
  case _C_ULNG_LNG:
    return ULL2NUM([self unsignedLongLongValue]);
  case _C_LNG_LNG:
    return LL2NUM([self longLongValue]);
  case _C_DBL:
  case _C_FLT:
    return DBL2NUM([self doubleValue]);
  case _C_ULNG:
    return ULONG2NUM([self unsignedLongValue]);
  case _C_LNG:
    return LONG2NUM([self longValue]);
  case _C_UINT:
    return UINT2NUM([self unsignedIntValue]);
  default:
    return INT2FIX([self intValue]);
  }
}

- (VALUE) getRubyInteger
{
  const char *type = [self objCType];

  switch (*type) {
  case _C_ULNG_LNG:
    return ULL2NUM([self unsignedLongLongValue]);
  case _C_LNG_LNG:
  case _C_DBL:
    return LL2NUM([self longLongValue]);
  case _C_ULNG:
    return ULONG2NUM([self unsignedLongValue]);
  case _C_FLT:
  case _C_LNG:
    return LONG2NUM([self longValue]);
  case _C_UINT:
    return UINT2NUM([self unsignedIntValue]);
  default:
    return INT2FIX([self intValue]);
  }
}

- (VALUE) getRubyFloat
{
  return DBL2NUM([self doubleValue]);
}

@end
