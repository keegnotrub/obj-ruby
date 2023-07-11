/* RIGSNSDate.m - Some additional code to properly wrap the
   NSDateclass in Ruby and provide some convenient new methods

   $Id$

   Copyright (C) 2023 thoughtbot, Inc.
   
   Written by:  Ryan Krug <ryan.krug@thoughtbot.com>
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

#include <ruby.h>
#undef _

#include <objc/runtime.h>
#include <math.h>

#include "RIGS.h"
#include "RIGSCore.h"
#include "RIGSProxyIMP.h"
#include "RIGSWrapObject.h"
#import "RIGSNSDate.h"

@implementation NSDate ( RIGSNSDate )

+ (BOOL) finishRegistrationOfRubyClass: (VALUE) ruby_class
{
  // Nothing to do for the moment
  return YES;
}

+ (id) dateWithRubyTime: (VALUE) ruby_time
{
  struct timespec ts;
  uint64_t nsecs;
  NSTimeInterval interval;
  
  ts = rb_time_timespec(ruby_time);
  nsecs = ts.tv_sec * 1000000000ull + ts.tv_nsec;
  interval = nsecs / 1E9;

  return [NSDate dateWithTimeIntervalSince1970:interval];
}

- (id) to_time
{
  return [RIGSWrapObject objectWithRubyObject:[self getRubyObject]];
}

- (VALUE) getRubyObject
{
  NSTimeInterval interval;
  NSTimeInterval secs;
  long nsecs;

  interval = [self timeIntervalSince1970];

  nsecs = modf(interval, &secs) * 1000000000l;

  return rb_time_nano_new((time_t)secs, nsecs);
}


@end
      
