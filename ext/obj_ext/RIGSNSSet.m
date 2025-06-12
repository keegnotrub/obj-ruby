/* RIGSNSSet.m - Some additional to properly wrap the
   NSSet class in Ruby and provide some new methods

   Written by: Ryan Krug <keegnotrub@icloud.com>
   Date: June 2025

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

#import "RIGSNSSet.h"
#import "RIGSCore.h"

static VALUE
rb_objc_set_i_convert(RB_BLOCK_CALL_FUNC_ARGLIST(i, memo))
{
  NSMutableSet *set;
  id elt;
  void *data;
  const char idType[] = {_C_ID,'\0'};

  set = (NSMutableSet *)memo;
  data = alloca(sizeof(id));
  data = &elt;

  rb_objc_convert_to_objc(i, &data, 0, idType);
  [set addObject:elt];

  return Qnil;
}

VALUE
rb_objc_set_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    NSSet *objc_set;
    VALUE rb_set;
    const char idType[] = {_C_ID,'\0'};

    objc_set = rb_objc_set_from_rb(rb_val, Qtrue);

    rb_objc_convert_to_rb((void *)&objc_set, 0, idType, &rb_set);

    return rb_set;
  }
}

VALUE
rb_objc_set_m_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    NSSet *objc_set;
    VALUE rb_set;
    const char idType[] = {_C_ID,'\0'};

    objc_set = rb_objc_set_from_rb(rb_val, Qfalse);

    rb_objc_convert_to_rb((void *)&objc_set, 0, idType, &rb_set);

    return rb_set;
  }
}

id
rb_objc_set_from_rb(VALUE rb_val, VALUE rb_frozen)
{
  NSMutableSet *set;

  set = [NSMutableSet set];
  rb_block_call(rb_val, rb_intern("each"), 0, 0, rb_objc_set_i_convert, (VALUE)set);

  if (rb_frozen == Qtrue) {
    return [[set copy] autorelease];
  }

  return set;
}
