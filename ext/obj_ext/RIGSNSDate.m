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

VALUE
rb_objc_date_to_time(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return rb_objc_date_to_rb(rcv);
  }
}

VALUE
rb_objc_date_to_rb(NSDate *val)
{
  NSTimeInterval interval;
  NSTimeInterval secs;
  long nsecs;
  
  interval = [val timeIntervalSince1970];
  nsecs = modf(interval, &secs) * 1000000000l;

  return rb_time_nano_new((time_t)secs, nsecs);
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
