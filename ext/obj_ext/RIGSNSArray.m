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

VALUE
rb_objc_array_store(VALUE rb_self, VALUE rb_idx, VALUE rb_val)
{
  @autoreleasepool {
    id rcv;
    id val;
    void *data;
    const char idType[] = {_C_ID,'\0'};

    Check_Type(rb_idx, T_FIXNUM);
    
    Data_Get_Struct(rb_self, void, rcv);

    data = alloca(sizeof(id));
    data = &val;
    rb_objc_convert_to_objc(rb_val, &data, 0, idType);

    [rcv setObject:val atIndexedSubscript:FIX2LONG(rb_idx)];
           
    return Qnil;
  }
}

VALUE
rb_objc_array_to_a(VALUE rb_self)
{
  @autoreleasepool {
    id rcv;

    Data_Get_Struct(rb_self, void, rcv);

    return rb_objc_array_to_rb(rcv);
  }  
}

VALUE
rb_objc_array_to_rb(NSArray *rcv)
{
  VALUE rb_array;
  VALUE rb_elt;
  const char idType[] = {_C_ID,'\0'};

  rb_array = rb_ary_new_capa([rcv count]);

  for (id objc_elt in rcv) {
    rb_objc_convert_to_rb((void *)&objc_elt, 0, idType, &rb_elt, YES);
    rb_ary_push(rb_array, rb_elt);
  }
  
  return rb_array;
}

NSArray*
rb_objc_array_from_rb(VALUE rb_val)
{
  NSArray *array;
  long i;
  long count;
  id *objects;
  VALUE rb_elt;
  void *data;
  const char idType[] = {_C_ID,'\0' };

  Check_Type(rb_val, T_ARRAY);
    
  // Loop through the elements of the ruby array and generate a NSArray
  count = rb_array_len(rb_val);
  objects = malloc(sizeof(id) * count);
  if (objects == NULL) {
    return nil;
  }

  // Loop through the elements of the ruby array, convert them to Objective-C
  // objects (only Objects id can go into an NSArray anyway) and feed them
  // into a new NSArray
  for (i = 0; i < count; i++) {
    rb_elt = rb_ary_entry(rb_val, i);

    data = &objects[i];
    rb_objc_convert_to_objc(rb_elt, &data, 0, idType);
  }

  array = [NSArray arrayWithObjects:objects count:count];
  free(objects);

  return array;
}
