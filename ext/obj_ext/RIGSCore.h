/* RIGSCore.h - Ruby Interface to Objective-C - main module

   Written by: Ryan Krug <keegnotrub@icloud.com>
   Date: April 2023

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

#ifndef __RIGSCore_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSCore_h_GNUSTEP_RUBY_INCLUDE

#import <Cocoa/Cocoa.h>
#include <objc/runtime.h>
#include <objc/message.h>
#include <ruby.h>
#include <dlfcn.h>
#include <ffi/ffi.h>

void  rb_objc_release(id objc_object);
VALUE rb_objc_new(int rigs_argc, VALUE *rigs_argv, VALUE rb_class);

BOOL rb_objc_convert_to_objc(VALUE rb_val, void **data, size_t offset, const char *type);
BOOL rb_objc_convert_to_rb(void *data, size_t offset, const char *type, VALUE *rb_val_ptr, BOOL autoconvert);

VALUE rb_objc_send(int rigs_argc, VALUE *rigs_argv, VALUE rb_self);
VALUE rb_objc_invoke(int rigs_argc, VALUE *rigs_argv, VALUE rb_self);

VALUE rb_objc_register_class_from_objc(Class objc_class);
VALUE rb_objc_register_class_from_rb(VALUE rb_class);
VALUE rb_objc_register_instance_method_from_rb(VALUE rb_class, VALUE rb_method);

void rb_objc_register_float_from_objc(const char *name, double value);
void rb_objc_register_integer_from_objc(const char *name, long long value);
void rb_objc_register_struct_from_objc(const char *key, const char *name, const char *args[], size_t argCount);
void rb_objc_register_format_string_from_objc(const char *selector, size_t index);
void rb_objc_register_block_from_objc(const char *selector, size_t index, const char *objcTypes);
void rb_objc_register_constant_from_objc(const char *name, const char *type);
void rb_objc_register_function_from_objc(const char *name, const char *objcTypes);
void rb_objc_register_protocol_from_objc(const char *protocolName);

VALUE rb_objc_require_framework_from_ruby(VALUE rb_self, VALUE rb_name);

void rb_objc_raise_exception(NSException *exception);

void Init_obj_ext();

#endif
