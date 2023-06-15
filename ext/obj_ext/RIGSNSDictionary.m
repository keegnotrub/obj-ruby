/* RIGSNSDictionary.m - Some additional code to properly wrap the
   NSDictionary class in Ruby and provide some convenient new methods

   $Id$

   Copyright (C) 2023 thoughtbot, Inc.
   
   Written by:  Ryan Krug <ryan.krug@thoughtbot.com>
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

#include <ruby.h>
#undef _

#include <objc/runtime.h>

#include "RIGS.h"
#include "RIGSCore.h"
#include "RIGSProxyIMP.h"
#include "RIGSWrapObject.h"

#import "RIGSNSDictionary.h"

static int rigs_ary_keys_i(VALUE key, VALUE value, VALUE ary) {
  rb_ary_push(ary, key);
  return ST_CONTINUE;
}

static int rigs_ary_values_i(VALUE key, VALUE value, VALUE ary) {
  rb_ary_push(ary, value);
  return ST_CONTINUE;
}

@implementation NSDictionary ( RIGSNSDictionary )

+ (BOOL) finishRegistrationOfRubyClass: (VALUE) ruby_class
{
  // Nothing to do for the moment
  return YES;
}

+ (id) dictionaryWithRubyHash: (VALUE) ruby_hash
{
  NSDictionary *returnDictionary;
  int i;
  int count;
  id *keyObjects;
  id *valueObjects;
  VALUE rb_key;
  VALUE rb_value;
  BOOL okydoky;
  VALUE ruby_keys;
  VALUE ruby_values;
  const char idType[] = {_C_ID,'\0' };
  
  // A nil value should not get there. It should be a 
  // Ruby Hash in any case
  if ( NIL_P(ruby_hash) || (TYPE(ruby_hash) != T_HASH) )
    return nil;

  // Loop through the elements of the ruby array and generate a NSArray
  count = RHASH_SIZE(ruby_hash);
  ruby_keys = rb_ary_new_capa(count);
  ruby_values = rb_ary_new_capa(count);

  rb_hash_foreach(ruby_hash, rigs_ary_keys_i, ruby_keys);
  rb_hash_foreach(ruby_hash, rigs_ary_values_i, ruby_values);
  
  keyObjects = malloc(sizeof(id) * count);
  valueObjects = malloc(sizeof(id) * count);
  if (keyObjects == NULL || valueObjects == NULL) {
      return nil;
  }

  // Loop through the elements of the ruby hash, convert them to Objective-C
  // objects (only Objects id can go into an NSArray anyway) and feed them
  // into a new NSDictionary
  for (i = 0; i < count; i++) {
      
    rb_key = rb_ary_entry(ruby_keys, (long)i);
    rb_value = rb_ary_entry(ruby_values, (long)i);
     
    okydoky = rb_objc_convert_to_objc(rb_key, &keyObjects[i], 0, idType);
    okydoky = rb_objc_convert_to_objc(rb_value, &valueObjects[i], 0, idType);
  }

  returnDictionary = [NSDictionary dictionaryWithObjects:valueObjects forKeys:keyObjects count:count];
  free(keyObjects);
  free(valueObjects);

  return returnDictionary;
}

- (id) to_h
{
  return [RIGSWrapObject objectWithRubyObject:[self getRubyObject]];
}

- (VALUE) getRubyObject
{
  const char idType[] = {_C_ID,'\0'};
  VALUE rb_hash;
  VALUE rb_key;
  VALUE rb_value;
  id objc_value;
  BOOL okydoky;

  rb_hash = rb_hash_new();

  for (id objc_key in self) {
    objc_value = [self objectForKey:objc_key];
    okydoky = rb_objc_convert_to_rb((void *)&objc_key, 0, idType, &rb_key, YES);
    okydoky = okydoky && rb_objc_convert_to_rb((void *)&objc_value, 0, idType, &rb_value, YES);
    if (okydoky)
      rb_hash_aset(rb_hash, rb_key, rb_value);
  }
  
  return rb_hash;
}


@end
      
