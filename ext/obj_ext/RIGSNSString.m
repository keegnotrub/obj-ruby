/* RIGSNSString.m - Some additional code to properly wrap the
   NSString class in Ruby

   $Id$

   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Laurent Julliard <laurent@julliard-online.org>
   Date: August 2001
   
   This file is part of the GNUstep RubyInterface Library.

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

#include <Foundation/NSString.h>

#include "RIGS.h"
#include "RIGSCore.h"
#include "RIGSWrapObject.h"
#import "RIGSNSString.h"



@implementation NSString ( RIGSNSString )

+ (BOOL) finishRegistrationOfRubyClass: (VALUE) rb_class
{

  // Nothing specific for the moment
  return YES;

}

+ (id) availableStringEncodingsAsRubyArray
{
  NSStringEncoding enc;
  NSStringEncoding * enc_ptr = [NSString availableStringEncodings];
  VALUE rb_ary = rb_ary_new();

  while ( (enc = *enc_ptr++) ) {
    rb_ary_push(rb_ary,INT2FIX((int)enc));
  }
  
  return [RIGSWrapObject objectWithRubyObject:rb_ary];
  
}

+ (id) stringWithRubyString:(VALUE)rb_string
{
  return [NSString stringWithCString: rb_string_value_cstr(&rb_string)];
}

+ (id) stringWithRubySymbol:(VALUE)rb_symbol
{
  return [NSString stringWithRubyString: rb_sym_to_s(rb_symbol)];
}

- (id) to_s
{
  return [RIGSWrapObject objectWithRubyObject:[self getRubyObject]];
}

- (VALUE) getRubyObject
{
  return rb_str_new_cstr([self cString]);
}

@end
      
