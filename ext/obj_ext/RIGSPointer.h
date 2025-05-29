/* RIGPointer.h - Some additional code to properly wrap the
   Objective-C pointer's in Ruby

   Written by: Ryan Krug <keegnotrub@icloud.com>
   Date: May 2025

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

#ifndef __RIGSPointer_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSPointer_h_GNUSTEP_RUBY_INCLUDE

#import <Foundation/Foundation.h>
#include <ruby.h>
#include <objc/runtime.h>

VALUE rb_objc_ptr_new(int rigs_argc, VALUE *rigs_argv, VALUE rb_class);
VALUE rb_objc_ptr_get(int rigs_argc, VALUE *rigs_argv, VALUE rb_self);
VALUE rb_objc_ptr_inspect(VALUE rb_self);

VALUE rb_objc_ptr_at(VALUE rb_val, int index);
VALUE rb_objc_ptr_slice(VALUE rb_val, int index, int length);

void rb_objc_ptr_ref(VALUE rb_val, void **data);

#endif
