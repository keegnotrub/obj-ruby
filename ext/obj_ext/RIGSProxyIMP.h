/*  RIGSProxyIMP.h - Actual forwarding functions to call Ruby method
    from  Objective C.

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

#ifndef __RIGSProxyIMP_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSProxyIMP_h_GNUSTEP_RUBY_INCLUDE

#include <ruby.h>
#undef _

#include <Foundation/NSObject.h>

/*
 * Register a Ruby class (and all its parent classes) with the 
 * objective-C runtime. 
 */
id _RIGS_id_IMP_RubyMethod (id rcv, SEL sel, ...);
Class _RIGS_Class_IMP_RubyMethod (id rcv, SEL sel, ...);
SEL _RIGS_SEL_IMP_RubyMethod (id rcv, SEL sel, ...);
void _RIGS_void_IMP_RubyMethod (id rcv, SEL sel, ...);
char *_RIGS_char_ptr_IMP_RubyMethod (id rcv, SEL sel, ...);
char _RIGS_char_IMP_RubyMethod (id rcv, SEL sel, ...);
unsigned char _RIGS_unsigned_char_IMP_RubyMethod (id rcv, SEL sel, ...);
short _RIGS_short_IMP_RubyMethod (id rcv, SEL sel, ...);
unsigned short _RIGS_unsigned_short_IMP_RubyMethod (id rcv, SEL sel, ...);
int _RIGS_int_IMP_RubyMethod (id rcv, SEL sel, ...);
unsigned int _RIGS_unsigned_int_IMP_RubyMethod (id rcv, SEL sel, ...);
long _RIGS_long_IMP_RubyMethod (id rcv, SEL sel, ...);
unsigned long _RIGS_unsigned_long_IMP_RubyMethod (id rcv, SEL sel, ...);
float _RIGS_float_IMP_RubyMethod (id rcv, SEL sel, ...);
double _RIGS_double_IMP_RubyMethod (id rcv, SEL sel, ...);

unsigned char _RIGS_guess_objc_return_type(VALUE rb_val);

#endif /*__RIGSProxyIMP_h_GNUSTEP_RUBY_INCLUDE*/
