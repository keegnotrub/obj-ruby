/* RIGSNSArray.m - Some additional code to properly wrap the
   NSArrayclass in Ruby and provide some convenient new methods

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

#import "RIGSNSArray.h"
#import "RIGSCore.h"

static int
rb_objc_array_i_convert(VALUE i, NSMutableArray *ary)
{
  id elt;
  void *data;

  data = alloca(sizeof(id));
  data = &elt;

  rb_objc_convert_to_objc(i, &data, 0, @encode(id));
  [ary addObject:elt];

  return ST_CONTINUE;
}

static VALUE
rb_objc_array_enum_size(VALUE ary, VALUE args, VALUE eobj)
{
  id rcv;

  Data_Get_Struct(ary, void, rcv);

  return ULONG2NUM([rcv count]);
}

VALUE
rb_objc_array_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    id objc_ary;
    VALUE rb_ary;

    if (rb_iv_get(CLASS_OF(rb_val), "@objc_class") != Qnil) {
      Data_Get_Struct(rb_val, void, objc_ary);
      if ([objc_ary classForCoder] == [NSArray class]) {
        return rb_val;
      }
    }

    objc_ary = rb_objc_array_from_rb(rb_val, Qtrue);

    rb_objc_convert_to_rb((void *)&objc_ary, 0, @encode(id), &rb_ary);

    return rb_ary;
  }
}

VALUE
rb_objc_array_m_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    id objc_ary;
    VALUE rb_ary;

    if (rb_iv_get(CLASS_OF(rb_val), "@objc_class") != Qnil) {
      Data_Get_Struct(rb_val, void, objc_ary);
      if ([objc_ary classForCoder] == [NSMutableArray class]) {
        return rb_val;
      }
    }
    
    objc_ary = rb_objc_array_from_rb(rb_val, Qfalse);

    rb_objc_convert_to_rb((void *)&objc_ary, 0, @encode(id), &rb_ary);

    return rb_ary;
  }
}

VALUE
rb_objc_array_each(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;
    VALUE rb_elt;

    Data_Get_Struct(rb_self, void, rcv);

    RETURN_SIZED_ENUMERATOR(rb_self, 0, 0, rb_objc_array_enum_size);

    for (id objc_elt in rcv) {
      rb_objc_convert_to_rb((void *)&objc_elt, 0, @encode(id), &rb_elt);
      rb_yield(rb_elt);
    }

    return rb_self;
  }  
}

VALUE
rb_objc_array_store(VALUE rb_self, VALUE rb_idx, VALUE rb_val)
{
  @autoreleasepool {
    id rcv;
    id val;
    void *data;

    Check_Type(rb_idx, T_FIXNUM);
    
    Data_Get_Struct(rb_self, void, rcv);

    data = alloca(sizeof(id));
    data = &val;
    rb_objc_convert_to_objc(rb_val, &data, 0, @encode(id));

    [rcv setObject:val atIndexedSubscript:rb_fix2long(rb_idx)];
           
    return Qnil;
  }
}

id
rb_objc_array_from_rb(VALUE rb_val, VALUE rb_frozen)
{
  NSMutableArray *ary;
  VALUE rb_tmp;
  long length;
  long i;

  rb_tmp = rb_check_array_type(rb_val);
  if (NIL_P(rb_tmp)) {
    rb_tmp = rb_ary_new3(1, rb_val);
  }

  length = RARRAY_LEN(rb_tmp);
  ary = [NSMutableArray arrayWithCapacity:length];

  for(i=0;i<length;i++) {
    rb_objc_array_i_convert(rb_ary_entry(rb_tmp, i), ary);
  }

  if (rb_frozen == Qtrue) {
    return [[ary copy] autorelease];
  }

  return ary;
}
