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
rb_objc_dictionary_keys(VALUE key, VALUE value, VALUE ary) {
  rb_ary_push(ary, key);
  return ST_CONTINUE;
}

static int
rb_objc_dictionary_values(VALUE key, VALUE value, VALUE ary) {
  rb_ary_push(ary, value);
  return ST_CONTINUE;
}

VALUE
rb_objc_dictionary_store(VALUE rb_self, VALUE rb_key, VALUE rb_val)
{
  @autoreleasepool {
    id rcv;
    id key;
    id val;
    void *data;
    const char idType[] = {_C_ID,'\0'};

    Data_Get_Struct(rb_self, void, rcv);

    data = alloca(sizeof(id));

    data = &key;
    rb_objc_convert_to_objc(rb_key, &data, 0, idType);

    data = &val;
    rb_objc_convert_to_objc(rb_val, &data, 0, idType);

    [rcv setObject:val forKeyedSubscript:key];

    return Qnil;
  }
}

VALUE
rb_objc_dictionary_to_h(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return rb_objc_dictionary_to_rb(rcv);
  }
}

VALUE
rb_objc_dictionary_to_rb(NSDictionary *val)
{
  VALUE rb_hash;
  VALUE rb_key;
  VALUE rb_value;
  id objc_value;
  const char idType[] = {_C_ID,'\0'};

  rb_hash = rb_hash_new();

  for (id objc_key in val) {
    objc_value = [val objectForKey:objc_key];
    if (rb_objc_convert_to_rb((void *)&objc_key, 0, idType, &rb_key, YES)) {
      rb_objc_convert_to_rb((void *)&objc_value, 0, idType, &rb_value, YES);
      rb_hash_aset(rb_hash, rb_key, rb_value);
    }
  }
  
  return rb_hash;
}

NSDictionary*
rb_objc_dictionary_from_rb(VALUE rb_val)
{
  NSDictionary *dictionary;
  long i;
  long count;
  void *keyData;
  void *valueData;
  id *keyObjects;
  id *valueObjects;
  VALUE rb_key;
  VALUE rb_value;
  VALUE ruby_keys;
  VALUE ruby_values;
  const char idType[] = {_C_ID,'\0' };

  Check_Type(rb_val, T_HASH);

  // Loop through the elements of the ruby array and generate a NSArray
  count = rb_hash_size_num(rb_val);
  ruby_keys = rb_ary_new_capa(count);
  ruby_values = rb_ary_new_capa(count);

  rb_hash_foreach(rb_val, rb_objc_dictionary_keys, ruby_keys);
  rb_hash_foreach(rb_val, rb_objc_dictionary_values, ruby_values);
  
  keyObjects = malloc(sizeof(id) * count);
  valueObjects = malloc(sizeof(id) * count);
  if (keyObjects == NULL || valueObjects == NULL) {
    return nil;
  }

  // Loop through the elements of the ruby hash, convert them to Objective-C
  // objects (only Objects id can go into an NSArray anyway) and feed them
  // into a new NSDictionary
  for (i = 0; i < count; i++) {
    rb_key = rb_ary_entry(ruby_keys, i);
    rb_value = rb_ary_entry(ruby_values, i);

    keyData = &keyObjects[i];
    rb_objc_convert_to_objc(rb_key, &keyData, 0, idType);

    valueData = &valueObjects[i];
    rb_objc_convert_to_objc(rb_value, &valueData, 0, idType);
  }

  dictionary = [NSDictionary dictionaryWithObjects:valueObjects forKeys:keyObjects count:count];
  free(keyObjects);
  free(valueObjects);

  return dictionary;
}
