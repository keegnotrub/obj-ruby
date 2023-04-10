/*  RIGSProxySetup.m - Tools to build `fake` Objc classes delivering 
   messages to Ruby objects.

   $Id$

   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Laurent Julliard <laurent@julliard-online.org>
   Date: Aug 2001 (inspired from Nicola Pero JIGSProxySetup.m)
   
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

#ifndef __RIGSProxySetup_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSProxySetup_h_GNUSTEP_RUBY_INCLUDE

#include <ruby.h>
#undef _

#include <Foundation/NSObject.h>

/*
 * These functions, methods and data tables are not public.
 */


/*
  FIXME: NOT USED FOR THE MOMENT - This was used in JIGS
 * This is a table to manage selectors->Ruby method ID.
 * Each class needs its little table, because jmethodIDs 
 * depend on the class.  
  
 * Class methods are [of course] registered as methods of the meta
 * class.  
 
 * This table makes forwarding faster by caching all the jmethodIDs.
 * Allocation is only slightly slower, because when we get a list of
 * the methods of a java class, which we are obliged to do at
 * allocation time, we get the jmethodIDs nearly for free.
 
 * Moreover, this table in principle allows the same selector to be
 * bounded to invoke different java methods when called on different
 * classes.  Viceversa, different selectors can invoke the same java
 * method on different classes.
 
 * Disadvantage: this table consumes memory.  This looks like a minor
 * problem nowadays - messaging speed seems more important.  */
struct _RIGSSelectorIDTable
{
  int classCount;       // Number of classes in the list
  
  // Each class has an entry like the following one:
  struct _RIGSSelectorIDEntry
    {
      Class class;      // Class
      VALUE rubyClass; // Cached pointer to the Java Class
      int selIDCount;   // Number of selector->ID entries for this class

      // The selector->ID entries for this class:
      struct _RIGSSelectorID 
	{
	  // Beware: the following Objc selector will be initialized with 
	  // the method name (char*).  This is replaced by the selector 
	  // after the method is registered with the runtime.
	  SEL selector;       // Objc Selector used to find the method later
	  char *types;        // Objc info on return type and arguments
	  ID methodID;        // Cache Ruby method ID
	  BOOL isConstructor; // YES for constructors
	  int numberOfArgs;   // Cached number of arguments
	} *selIDTable; // The table itself
    } *classTable;
};

/*
 * Register a Ruby class (and all its parent classes) with the 
 * objective-C runtime. 
 */
int _RIGS_ruby_method_arity(const char *rb_class_name, const char *rb_mth_name);
Class  _RIGS_register_ruby_class (VALUE rb_class);
VALUE _RIGS_register_ruby_class_from_ruby (VALUE self, VALUE rb_class);
BOOL _RIGS_build_objc_types(VALUE rb_class, const char *rb_mth_name,
			    const char retValueType, int nbArgs, char *sigBuf);

#endif /*__RIGSProxySetup_h_GNUSTEP_RUBY_INCLUDE*/
