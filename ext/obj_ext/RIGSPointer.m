/* RIGPointer.m - Some additional code to properly wrap the
   Objective-C pointer's in Ruby

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

#import "RIGSPointer.h"
#import "RIGSUtilities.h"
#import "RIGSCore.h"

void
rb_objc_ptr_release(struct rb_objc_ptr *dp)
{
  @autoreleasepool {
    id obj;
    size_t offset;

    if (dp == NULL) return;

    NSDebugLog(@"Call to ObjRuby::Pointer release on %p", dp);
    
    if (dp->retained) {
      offset = 0;
      while (offset < dp->allocated_size) {
        obj = *((id*)(dp->cptr) + offset);
        if ([obj respondsToSelector:@selector(release)]) {
          [obj release];
        }
        offset += sizeof(id);
      }        
    }

    if (dp->allocated_size > 0) free(dp->cptr);
    if (dp->encoding) free((char*)dp->encoding);

    dp->allocated_size = 0;
    dp->cptr = NULL;
    dp->encoding = NULL;
    dp->retained = NO;

    free(dp);
  }
}

VALUE
rb_objc_ptr_new(int rigs_argc, VALUE *rigs_argv, VALUE rb_class)
{
  @autoreleasepool {
    VALUE obj;
    VALUE enc;
    VALUE cnt;
    const char *encoding;
    ID key;
    const char* (*types)[2];
    char *data;
    NSUInteger tsize;
    struct rb_objc_ptr *dp;

    rigs_argc = rb_scan_args(rigs_argc, rigs_argv, "11", &enc, &cnt);

    switch (TYPE(enc)) {
    case T_SYMBOL:
      encoding = NULL;
      key = rb_to_id(enc);
      types = rb_objc_ptr_types;
      while ((*types)[0] != NULL) {
        if (rb_intern((*types)[0]) == key) {
          encoding = (*types)[1];
          break;
        }
        types++;
      }
      break;
    case T_STRING:
      encoding = rb_string_value_cstr(&enc);
      break;
    default:
      encoding = NULL;
      break;
    }

    if (encoding == NULL) {
      enc = rb_inspect(enc);
      rb_raise(rb_eTypeError, "unsupported encoding -- %s", rb_string_value_cstr(&enc));
    }

    if (rigs_argc == 2) {
      Check_Type(cnt, T_FIXNUM);
    }

    dp = (struct rb_objc_ptr*)malloc(sizeof(struct rb_objc_ptr));
    dp->retained = NO;

    data = malloc(sizeof(char) * (strlen(encoding) + 1));
    strcpy(data, encoding);
    dp->encoding = data;

    tsize = 0;
    NSGetSizeAndAlignment(encoding, &tsize, NULL);
    tsize *= rigs_argc == 2 ? FIX2INT(cnt) : 1;

    if (tsize > 0) {
      dp->cptr = (void*)malloc(tsize);
      memset(dp->cptr, 0, tsize);
      dp->allocated_size = tsize;
    }
    else {
      dp->cptr = NULL;
      dp->allocated_size = 0;
    }
    
    obj = Data_Wrap_Struct(rb_class, 0, rb_objc_ptr_release, dp);

    return obj;
  }
}

VALUE
rb_objc_ptr_get(VALUE rb_self, VALUE index)
{
  @autoreleasepool {
    NSUInteger offset;
    struct rb_objc_ptr *dp;
    VALUE val;
    BOOL converted;

    Check_Type(index, T_FIXNUM);
  
    dp = (struct rb_objc_ptr*)DATA_PTR(rb_self);

    converted = NO;
    offset = 0;
    if (dp->encoding != NULL) {
      NSGetSizeAndAlignment(dp->encoding, &offset, NULL);
      offset *= FIX2INT(index);

      if (dp->allocated_size > 0) {
        converted = rb_objc_convert_to_rb(dp->cptr, offset, dp->encoding, &val, NO);
      }
    }

    if (!converted) {
      rb_raise(rb_eRuntimeError, "can't convert element of type '%s' at index %d with offset %lu",
               dp->encoding ?: "(unknown)", FIX2INT(index), offset);
    }

    return val;
  }
}

VALUE
rb_objc_ptr_inspect(VALUE rb_self)
{
  @autoreleasepool {
    char s[512];
    VALUE rb_class;
    struct rb_objc_ptr *dp;

    rb_class = rb_mod_name(CLASS_OF(rb_self));
    dp = (struct rb_objc_ptr*)DATA_PTR(rb_self);
  
    snprintf(s, sizeof(s), "#<%s:%p cptr=%p allocated_size=%ld encoding=%s>",
             rb_string_value_cstr(&rb_class),
             (void*)rb_self,
             dp->cptr,
             dp->allocated_size,
             dp->encoding ?: "(NULL)");
  
    return rb_str_new2(s);  
  }
}

void
rb_objc_ptr_retain(VALUE rb_self)
{
  struct rb_objc_ptr *dp;
  id obj;
  size_t offset = 0;

  dp = (struct rb_objc_ptr*)DATA_PTR(rb_self);

  if (dp->allocated_size == 0) return;
  if (dp->encoding == NULL) return;
  if (*(dp->encoding) != _C_ID) return;

  while (offset < dp->allocated_size) {
    obj = *((id*)(dp->cptr) + offset);
    if ([obj respondsToSelector:@selector(retain)]) {
      [obj retain];
    }
    offset += sizeof(id);
  }

  dp->retained = YES;
}
