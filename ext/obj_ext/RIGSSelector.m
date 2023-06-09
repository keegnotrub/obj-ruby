/* RIGSSelector.m - Managing mapping between Objective-C method 
   names and Rubyones

   $Id$

   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Laurent Julliard <laurent@julliard-online.org>
   Date: October 2000
   
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

#include <Foundation/NSObject.h>
#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>


#include "RIGS.h"
#include "RIGSWrapObject.h"
#include "RIGSSelector.h"


@implementation RIGSSelector : NSObject

+ (id) selectorWithCString: (char *) selCString
{
  return [[RIGSSelector alloc] initSelectorWithCString: selCString];
}

+ (id) selectorWithString: (NSString*) selString
{
  return [[RIGSSelector alloc] initSelectorWithString: selString];
}

+ (id) selectorWithSEL: (SEL) sel
{
  return [[RIGSSelector alloc] initSelectorWithSEL: sel];
}

+ (id) selectorWithRubyString: (VALUE) rbString
{
  return [[RIGSSelector alloc] initWithRubyString: rbString];
}

- (id) initSelectorWithCString: (char *) selCString
{
  self = [self init];
  
  NSDebugLog(@"Creating a new Selector for C string SEL %s",selCString);
  _sel = NSSelectorFromString([NSString stringWithCString: selCString]);
  return self;
}

- (id) initSelectorWithString: (NSString*) selString
{
  self = [self init];
  
  NSDebugLog(@"Creating a new Selector for NSString SEL %@",selString);
  _sel = NSSelectorFromString(selString);
  return self;
}

- (id) initSelectorWithSEL: (SEL) sel
{
  self = [self init];
  
  NSDebugLog(@"Creating a new Selector for SEL %@",NSStringFromSelector(sel));
  _sel = sel;
  return self;
}

- (id) initWithRubyString: (VALUE) rbString
{
  self = [self init];

  NSString *selString = [NSString stringWithCString: rb_string_value_cstr(&rbString)];
  NSDebugLog(@"Creating a new Selector for Ruby string SEL %@",selString);
  _sel = NSSelectorFromString(selString);
  return self;
}

- (SEL) getSEL
{
  return _sel;
}

- (id) to_s
{
  return [RIGSWrapObject objectWithRubyObject:[self getRubyString]];
}

- (VALUE) getRubyString
{
  return rb_str_new_cstr(sel_getName(_sel));
}

@end

// Some conversion functions from Ruby names to ObjC selectors (SEL)
// They are not really realted to the RIGSSelector class but they fit well
// in there


NSString *
SelectorStringFromRubyName (char *name, int numArgs)
{
	id selname  = [NSString stringWithCString: name];

  // Allow Ruby-ish conversion to pass (to_s, to_i, to_f, to_a, to_h, etc)
  if (numArgs == 0 && [selname hasPrefix:@"to_"])
    return selname;
        
	selname = [[selname componentsSeparatedByString: @"_"]
				componentsJoinedByString: @":"];

        // Setters in Ruby often end with an "=" sign. Drop it.
	if([selname hasSuffix: @"="])
          selname = [selname substringToIndex: [selname length] - 1];
			

        /* Figure out how many colons we need to add at the end
                  (this is for ObjC methods with unnamed arguments in the
                  method selector) */
        {
          int i;
          int curNum = 0;
          char *ch = name;

          // How many underscores are in the  Ruby method name
          while (*ch++) {
            if(*ch == '_') ++curNum;
          }

          // Add missing ":" at the end
          if (numArgs > curNum) {
            selname = [selname stringByAppendingString: @":"];
          }
        }

	return (selname);
}

SEL
SelectorFromRubyName (char *name, int numArgs)
{
  return NSSelectorFromString(SelectorStringFromRubyName(name, numArgs));
}

NSString *
RubyNameFromSelector(SEL sel)
{
    return RubyNameFromSelectorString(NSStringFromSelector(sel));
}

NSString *
RubyNameFromSelectorString(NSString *name)
{
    
    name = [[name componentsSeparatedByString: @":"]
              componentsJoinedByString: @"_"];

    /* Can have multiple _ at the end if the ObjC method doesn't use
           named arguments like:
           + (void)DrawRect: (float)x1 :(float)y1 :(float)x2 :(float)y2;
      */
    while ([name hasSuffix: @"_"])
        name = [name substringToIndex: [name length] - 1];

    return name;
}
