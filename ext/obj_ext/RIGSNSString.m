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

VALUE
rb_objc_string_to_s(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return rb_objc_string_to_rb(rcv);
  }
}

VALUE
rb_objc_string_to_rb(NSString *val)
{
  return rb_str_new_cstr([val UTF8String]);
}

NSString*
rb_objc_string_from_rb(VALUE rb_val)
{
  Check_Type(rb_val, T_STRING);
  
  return [NSString stringWithUTF8String:rb_string_value_cstr(&rb_val)];
}
