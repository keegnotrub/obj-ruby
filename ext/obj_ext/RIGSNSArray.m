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

@implementation NSArray ( RIGSNSArray )

+ (id) arrayWithRubyArray: (VALUE) ruby_array
{
  NSArray *array = [NSArray alloc];
  NSArray *returnArray;
  long i;
  long count;
  id *objects;
  VALUE rb_elt;
  void *data;
  const char idType[] = {_C_ID,'\0' };
  
  // A nil value should not get there. It should be a 
  // Ruby Array in any case
  if ( NIL_P(ruby_array) || (TYPE(ruby_array) != T_ARRAY) )
    return nil;
    
  // Loop through the elements of the ruby array and generate a NSArray
  count = rb_array_len(ruby_array);
  objects = malloc(sizeof(id) * count);
  if (objects == NULL) {
    return nil;
  }

  // Loop through the elements of the ruby array, convert them to Objective-C
  // objects (only Objects id can go into an NSArray anyway) and feed them
  // into a new NSArray
  for (i = 0; i < count; i++) {
    rb_elt = rb_ary_entry(ruby_array, i);

    if (NIL_P(rb_elt)) {
      objects[i] = [NSNull null];
    }
    else {
      data = &objects[i];
      rb_objc_convert_to_objc(rb_elt, &data, 0, idType);
    }
  }

  returnArray = [array initWithObjects:objects count:count];
  free(objects);

  return returnArray;
}

- (VALUE) getRubyObject
{
  const char idType[] = {_C_ID,'\0'};
  VALUE rb_array;
  VALUE rb_elt;

  rb_array = rb_ary_new_capa([self count]);

  for (id objc_elt in self) {
    rb_objc_convert_to_rb((void *)&objc_elt, 0, idType, &rb_elt, YES);
    rb_ary_push(rb_array, rb_elt);
  }
  
  return rb_array;
}

@end
