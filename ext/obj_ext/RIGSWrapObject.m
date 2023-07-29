/* RIGSWrapObject.m - Wrapping Ruby Objects into GNUstep-like objects
   Copyright (C) 2001 Free Software Foundation, Inc.

   $Id$
   
   Written by:  Laurent Julliard
   Date: July 2001
   
   This file is part of the GNUstep Ruby Interface Library.

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

/*
  The RIGSWrapObject class provides a fallback mechanism to
  handle all Ruby native Objects passed to ObjC for which there is
  no specific conversion mechanism. Any method called from ObjC
  on this kind of object will be redirected to the forwardInvocation
  method
*/

#import "RIGSWrapObject.h"
#import "RIGSCore.h"
#import "RIGS.h"

static NSMapTable *knownRubyObjects = 0;

@implementation RIGSWrapObject : NSObject


+ (void) initialize
{
  if (self == [RIGSWrapObject self]) {
    knownRubyObjects = NSCreateMapTable(NSIntegerMapKeyCallBacks,
                                        NSObjectMapValueCallBacks,
                                        0);
  }
}

+ (id) objectWithRubyObject: (VALUE)rubyObject
{
  id obj;

  if (!(obj = NSMapGet(knownRubyObjects, rubyObject))) {
    obj = [[self alloc] initWithRubyObject: rubyObject];
  }

  return obj;
}

- (void) dealloc
{
  NSDebugLog(@"Deallocating RIGSWrapObject 0x%lx", self);

  NSMapRemove(knownRubyObjects, _ro);
  
  [super dealloc];
}

- (VALUE) getRubyObject
{
  return _ro;
}

- (NSString *) description
{
  VALUE rbval = rb_any_to_s(_ro);
  return( [NSString stringWithCString:
                      rb_string_value_cstr(&rbval)] );
}

- (NSString *) debugDescription
{
  VALUE rbval = rb_inspect(_ro);
  return( [NSString stringWithCString:
                      rb_string_value_cstr(&rbval)] );
}


- (id) initWithRubyObject: (VALUE)rubyObject
{
  /* FIXME:  how do we known when the wrapped ruby object has
     been disposed of on the Ruby side and we must delete the 
     corresponding RIGSWrapObject ?? */
  if ((self = [self init])) {
    _ro = rubyObject;
    NSMapInsertIfAbsent(knownRubyObjects, _ro, self);
  }
  return self;
}

@end
