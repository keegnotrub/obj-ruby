/* RIGSNSObject.h - Some additional stuff to properly wrap the
   NSObject class in Ruby

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

#ifndef __RIGSNSObject_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSNSObject_h_GNUSTEP_RUBY_INCLUDE

#import <Foundation/Foundation.h>
#include <ruby.h>

VALUE rb_objc_object_compare(VALUE rb_self, VALUE rb_val);
VALUE rb_objc_object_equal(VALUE rb_self, VALUE rb_val);
VALUE rb_objc_object_to_s(VALUE rb_self);
VALUE rb_objc_object_inspect(VALUE rb_self);
VALUE rb_objc_object_pretty_print(VALUE rb_self, VALUE rb_pp);
VALUE rb_objc_object_is_kind_of(VALUE rb_self, VALUE rb_class);
VALUE rb_objc_object_is_instance_of(VALUE rb_self, VALUE rb_class);
VALUE rb_objc_object_inherited(VALUE rb_class, VALUE rb_subclass);
VALUE rb_objc_object_method_added(VALUE rb_class, VALUE rb_method);

#endif
