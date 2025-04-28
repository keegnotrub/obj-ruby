/* RIGSNSDate.h - Some additional to properly wrap the
   NSDate class in Ruby and provide some new methods

   Written by: Ryan Krug <ryank@kit.com>
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

#ifndef __RIGSNSDate_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSNSDate_h_GNUSTEP_RUBY_INCLUDE

#import <Foundation/Foundation.h>
#include <ruby.h>
#include <math.h>
#include <time.h>

// Extend NSDate with a couple of new methods
@interface NSDate ( RIGSNSDate )

+ (id) dateWithRubyTime: (VALUE) ruby_time;

- (VALUE) getRubyObject;

@end

#endif
