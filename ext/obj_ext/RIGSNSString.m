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

@implementation NSString ( RIGSNSString )

+ (id) stringWithRubyString:(VALUE)rb_string
{
  return [NSString stringWithUTF8String: rb_string_value_cstr(&rb_string)];
}

+ (id) stringWithRubySymbol:(VALUE)rb_symbol
{
  return [NSString stringWithRubyString: rb_sym_to_s(rb_symbol)];
}

- (VALUE) getRubyObject
{
  return rb_str_new_cstr([self UTF8String]);
}

@end
