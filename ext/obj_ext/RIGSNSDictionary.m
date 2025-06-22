/* RIGSNSDictionary.m - Some additional code to properly wrap the
   NSDictionary class in Ruby and provide some convenient new methods

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

#import "RIGSNSDictionary.h"
#import "RIGSCore.h"

static int
rb_objc_dictionary_i_convert(VALUE k, VALUE v, VALUE memo)
{
  NSMutableDictionary *dict;
  id key;
  id val;
  void *data;

  dict = (NSMutableDictionary *)memo;

  data = alloca(sizeof(id));

  data = &key;
  rb_objc_convert_to_objc(k, &data, 0, @encode(id));
  data = &val;
  rb_objc_convert_to_objc(v, &data, 0, @encode(id));

  dict[key] = val;
    
  return ST_CONTINUE;
}

static VALUE
rb_objc_dictionary_enum_size(VALUE ary, VALUE args, VALUE eobj)
{
  id rcv;

  Data_Get_Struct(ary, void, rcv);

  return ULONG2NUM([rcv count]);
}

VALUE
rb_objc_dictionary_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    id objc_dict;
    VALUE rb_dict;

    if (rb_iv_get(CLASS_OF(rb_val), "@objc_class") != Qnil) {
      Data_Get_Struct(rb_val, void, objc_dict);
      if ([objc_dict classForCoder] == [NSDictionary class]) {
        return rb_val;
      }
    }

    objc_dict = rb_objc_dictionary_from_rb(rb_val, Qtrue);

    rb_objc_convert_to_rb((void *)&objc_dict, 0, @encode(id), &rb_dict);

    return rb_dict;
  }  
}

VALUE
rb_objc_dictionary_m_convert(VALUE rb_module, VALUE rb_val)
{
  @autoreleasepool {
    id objc_dict;
    VALUE rb_dict;

    if (rb_iv_get(CLASS_OF(rb_val), "@objc_class") != Qnil) {
      Data_Get_Struct(rb_val, void, objc_dict);
      if ([objc_dict classForCoder] == [NSMutableDictionary class]) {
        return rb_val;
      }
    }

    objc_dict = rb_objc_dictionary_from_rb(rb_val, Qfalse);

    rb_objc_convert_to_rb((void *)&objc_dict, 0, @encode(id), &rb_dict);

    return rb_dict;
  }  
}

VALUE
rb_objc_dictionary_each_key(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;
    VALUE rb_key;

    Data_Get_Struct(rb_self, void, rcv);

    RETURN_SIZED_ENUMERATOR(rb_self, 0, 0, rb_objc_dictionary_enum_size);

    for (id objc_key in rcv) {
      rb_objc_convert_to_rb((void *)&objc_key, 0, @encode(id), &rb_key);
      rb_yield(rb_key);
    }

    return rb_self;
  }  
}

VALUE
rb_objc_dictionary_each_value(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;
    id objc_val;
    VALUE rb_val;

    Data_Get_Struct(rb_self, void, rcv);

    RETURN_SIZED_ENUMERATOR(rb_self, 0, 0, rb_objc_dictionary_enum_size);

    for (id objc_key in rcv) {
      objc_val = rcv[objc_key];
      rb_objc_convert_to_rb((void *)&objc_val, 0, @encode(id), &rb_val);
      rb_yield(rb_val);
    }

    return rb_self;
  }  
}

VALUE rb_objc_dictionary_each_pair(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;
    id objc_val;
    VALUE rb_key;
    VALUE rb_val;

    Data_Get_Struct(rb_self, void, rcv);

    RETURN_SIZED_ENUMERATOR(rb_self, 0, 0, rb_objc_dictionary_enum_size);

    for (id objc_key in rcv) {
      objc_val = rcv[objc_key];
      rb_objc_convert_to_rb((void *)&objc_key, 0, @encode(id), &rb_key);
      rb_objc_convert_to_rb((void *)&objc_val, 0, @encode(id), &rb_val);
      rb_yield_values(2, rb_key, rb_val);
    }

    return rb_self;
  }  
}

VALUE
rb_objc_dictionary_store(VALUE rb_self, VALUE rb_key, VALUE rb_val)
{
  @autoreleasepool {
    id rcv;
    id key;
    id val;
    void *data;

    Data_Get_Struct(rb_self, void, rcv);

    data = alloca(sizeof(id));

    data = &key;
    rb_objc_convert_to_objc(rb_key, &data, 0, @encode(id));

    data = &val;
    rb_objc_convert_to_objc(rb_val, &data, 0, @encode(id));

    [rcv setObject:val forKeyedSubscript:key];

    return Qnil;
  }
}

id
rb_objc_dictionary_from_rb(VALUE rb_val, VALUE rb_frozen)
{
  NSMutableDictionary *dict;
  VALUE rb_tmp;
  const char *cname;
  long size;

  rb_tmp = rb_check_hash_type(rb_val);
  if (NIL_P(rb_tmp)) {
    cname = rb_frozen == Qtrue ? "NSDictionary" : "NSMutableDictionary";
    rb_raise(rb_eTypeError, "can't convert %"PRIsVALUE" into %s", rb_val, cname);
  }

  size = rb_hash_size(rb_tmp);
  dict = [NSMutableDictionary dictionaryWithCapacity:size];
  
  rb_hash_foreach(rb_tmp, rb_objc_dictionary_i_convert, (VALUE)dict);

  if (rb_frozen == Qtrue) {
    return [[dict copy] autorelease];
  }
  
  return dict;
}
