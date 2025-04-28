/* RIGSNSNumber.h - Some additional to properly wrap the
   NSNumber class in Ruby and provide some new methods

   Written by: Ryan Krug <ryank@kit.com>
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

#ifndef __RIGSNSNumber_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSNSNumber_h_GNUSTEP_RUBY_INCLUDE

#import <Foundation/Foundation.h>
#include <ruby.h>
#include <objc/runtime.h>

// Extend NSNumber with a couple of new methods
@interface NSNumber ( RIGSNSNumber )

+ (id) numberWithRubyBignum: (VALUE) rb_bignum;
+ (id) numberWithRubyFixnum: (VALUE) rb_fixnum;
+ (id) numberWithRubyFloat: (VALUE) rb_float;
+ (id) numberWithRubyBool: (VALUE) rb_bool;

- (VALUE) getRubyObject;
- (VALUE) getRubyInteger;
- (VALUE) getRubyFloat;

@end

#endif
