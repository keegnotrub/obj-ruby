/* RIGSNSDictionary.h - Some additional to properly wrap the
   NSDictionary class in Ruby and provide some new methods

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

#ifndef __RIGSNSDictionary_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSNSDictionary_h_GNUSTEP_RUBY_INCLUDE


#include <ruby.h>
#undef _

#include <Foundation/NSDictionary.h>
#include "RIGSWrapObject.h"


// Extend NSDictionary with a couple of new methods
@interface NSDictionary ( RIGSNSDictionary )

+ (BOOL) finishRegistrationOfRubyClass: (VALUE) ruby_class;
+ (id) dictionaryWithRubyHash: (RIGSWrapObject *) wrapped_ruby_hash;

@end

#endif
