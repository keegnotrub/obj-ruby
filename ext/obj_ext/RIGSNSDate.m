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

#import "RIGSNSDate.h"
#import "RIGSCore.h"
#import "RIGSWrapObject.h"

@implementation NSDate ( RIGSNSDate )

+ (id) dateWithRubyTime: (VALUE) ruby_time
{
  NSTimeInterval seconds;
  seconds = NUM2DBL(rb_funcall(ruby_time, rb_intern("to_f"), 0));
  return [NSDate dateWithTimeIntervalSince1970:seconds]; 
}

- (id) to_time
{
  return [RIGSWrapObject objectWithRubyObject:[self getRubyObject]];
}

- (VALUE) getRubyObject
{
  NSTimeInterval interval = [self timeIntervalSince1970];
  NSTimeInterval secs;
  NSTimeInterval usecs;

  usecs = modf(interval, &secs);

  return rb_time_nano_new(secs, (long)floor(usecs * 1000000000.0));
}


@end
      
