/* RIGSNSString.h - Some additional stuff to properly wrap the
   NSString class in Ruby

   $Id$

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

#ifndef __RIGSNSString_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSNSString_h_GNUSTEP_RUBY_INCLUDE

#import <Foundation/Foundation.h>
#include <ruby.h>

// Extend NSApplication with some finishing registration code
@interface NSString ( RIGSNSString )

+ (id) stringWithRubyString: (VALUE)rb_string;
+ (id) stringWithRubySymbol: (VALUE)rb_symbol;

- (id) to_s;
- (VALUE) getRubyObject;

@end


#endif
