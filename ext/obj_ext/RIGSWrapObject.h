/* RIGSWrapObject.h - Wrapping Ruby Objects into GNUstep-like objects
   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Laurent Julliard <laurent@julliard-online.org>
   Date: July 2001
   
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

#ifndef __RIGSWrapObject_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSWrapObject_h_GNUSTEP_RUBY_INCLUDE

#include <ruby.h>
#undef _ /* must do it to avoid conflict with the following include */

#import <Foundation/NSObject.h>

@interface RIGSWrapObject : NSObject
{
  VALUE _ro; /* ruby object */
}
+ (void) initialize;
+ (id) objectWithRubyObject: (VALUE)rubyObject;

- (void) dealloc;
- (VALUE) getRubyObject;
- (NSString *) description;
- (NSString *) debugDescription;
- (id) initWithRubyObject: (VALUE)rubyObject;
- (void) forwardInvocation: (NSInvocation *)anInvocation;
- (BOOL) respondsToSelector: (SEL)aSelector;

- (id) performSelector: (SEL)aSelector;
- (id) performSelector: (SEL)aSelector withObject: anObject;
- (id) performSelector: (SEL)aSelector withObject: object1 withObject: object2;

@end


#endif
