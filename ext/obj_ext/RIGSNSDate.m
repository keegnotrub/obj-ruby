/* RIGSNSDate.m - Some additional code to properly wrap the
   NSDateclass in Ruby and provide some convenient new methods

   Written by: Ryan Krug <keegnotrub@icloud.com>
   Date: June 2023

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

#import "RIGSNSDate.h"
#import "RIGSCore.h"

VALUE
rb_objc_date_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    id objc_date;
    VALUE rb_date;

    if (rb_iv_get(CLASS_OF(rb_val), "@objc_class") != Qnil) {
      Data_Get_Struct(rb_val, void, objc_date);
      if ([objc_date classForCoder] == [NSDate class]) {
        return rb_val;
      }
    }
    
    objc_date = rb_objc_date_from_rb(rb_val);

    rb_objc_convert_to_rb((void *)&objc_date, 0, @encode(id), &rb_date);

    return rb_date;
  }  
}

VALUE
rb_objc_date_compare(VALUE rb_self, VALUE rb_val)
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
    if (![objc_class isSubclassOfClass:[NSDate class]]) {
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
rb_objc_date_to_time(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;
    NSTimeInterval interval;
    NSTimeInterval secs;
    long nsecs;
  
    Data_Get_Struct(rb_self, void, rcv);
    
    interval = [rcv timeIntervalSince1970];
    nsecs = modf(interval, &secs) * 1000000000l;

    return rb_time_nano_new((time_t)secs, nsecs);
  }
}

NSDate*
rb_objc_date_from_rb(VALUE rb_val)
{
  struct timespec ts;
  uint64_t nsecs;
  NSTimeInterval interval;
  
  ts = rb_time_timespec(rb_val);
  nsecs = ts.tv_sec * 1000000000ull + ts.tv_nsec;
  interval = nsecs / 1E9;

  return [NSDate dateWithTimeIntervalSince1970:interval];
}
