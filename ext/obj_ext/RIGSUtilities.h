/* RIGSUtilities.h - Utilities to add classes and methods 
   in the Objective-C runtime, at runtime.

   Written by: Ryan Krug <keegnotrub@icloud.com>
   Date: July 2023

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

#ifndef __RIGSUtilities_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSUtilities_h_GNUSTEP_RUBY_INCLUDE

#include <objc/runtime.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#ifndef NSDebugLog
#define NSDebugLog(fmt, ...) \
  do { if (0) NSLog(fmt, ##__VA_ARGS__); } while (0)
#endif

#define ROUND(V, A)                             \
  ({ typeof(V) __v=(V); typeof(A) __a=(A);      \
    __a*((__v+__a-1)/__a); })

SEL rb_objc_method_to_sel(const char* name, int argc);
char *rb_objc_sel_to_method(SEL sel);
char *rb_objc_sel_to_alias(SEL sel);

unsigned long rb_objc_hash(const char *value);
unsigned long rb_objc_hash_struct(const char *value);
const char *rb_objc_skip_type_qualifiers(const char *type);
const char *rb_objc_skip_type_sname(const char *type);
const char *rb_objc_skip_typespec(const char *type);

#endif /* __RIGSUtilitis_h_GNUSTEP_RUBY_INCLUDE */
