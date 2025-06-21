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
#import "RIGSCore.h"
#import "RIGSUtilities.h"

struct rb_objc_ptr
{
  unsigned long allocated_size;
  void *cptr;
  const char *encoding;
};

static const char* rb_objc_ptr_types[][2] = {
  {     "object", @encode(id) },
  {       "bool", @encode(BOOL) },
  {       "char", @encode(char) },
  {      "uchar", @encode(unsigned char) },
  {      "short", @encode(short) },
  {     "ushort", @encode(unsigned short) },
  {        "int", @encode(int) },
  {       "uint", @encode(unsigned int) },
  {       "long", @encode(long) },
  {      "ulong", @encode(unsigned long) },
  {  "long_long", @encode(long long) },
  { "ulong_long", @encode(unsigned long long) },
  {      "float", @encode(float) },
  {     "double", @encode(double) },
  {        NULL, NULL }
};

void
rb_objc_ptr_release(struct rb_objc_ptr *dp)
{
  @autoreleasepool {
    if (dp == NULL) return;

    if (dp->allocated_size > 0) free(dp->cptr);
    if (dp->encoding) free((char*)dp->encoding);

    dp->allocated_size = 0;
    dp->cptr = NULL;
    dp->encoding = NULL;

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

    data = malloc(sizeof(char) * (strlen(encoding) + 1));
    strcpy(data, encoding);
    dp->encoding = data;

    tsize = 0;
    NSGetSizeAndAlignment(encoding, &tsize, NULL);
    tsize *= rigs_argc == 2 ? FIX2INT(cnt) : 1;

    dp->cptr = (void*)malloc(tsize);
    memset(dp->cptr, 0, tsize);
    dp->allocated_size = tsize;

    obj = Data_Wrap_Struct(rb_class, 0, rb_objc_ptr_release, dp);

    return obj;
  }
}

VALUE
rb_objc_ptr_get(int rigs_argc, VALUE *rigs_argv, VALUE rb_self)
{
  @autoreleasepool {
    VALUE index;
    VALUE length;

    rigs_argc = rb_scan_args(rigs_argc, rigs_argv, "11", &index, &length);

    switch(rigs_argc) {
    case 1:
      Check_Type(index, T_FIXNUM);
      return rb_objc_ptr_at(rb_self, FIX2INT(index));
    case 2:
      Check_Type(index, T_FIXNUM);
      Check_Type(length, T_FIXNUM);
      return rb_objc_ptr_slice(rb_self, FIX2INT(index), FIX2INT(length));
    default:
      rb_raise(rb_eArgError, "wrong number of arguments");
    }
  }
}

VALUE
rb_objc_ptr_store(VALUE rb_self, VALUE rb_idx, VALUE rb_val)
{
  @autoreleasepool {
    struct rb_objc_ptr *dp;
    long index;
    size_t tsize;
    size_t offset;
    long ioffset;
    
    Check_Type(rb_idx, T_FIXNUM);

    index = FIX2INT(rb_idx);
    dp = (struct rb_objc_ptr*)DATA_PTR(rb_self);

    if (dp->allocated_size == 0) rb_raise(rb_eIndexError, "index %ld is invalid for an empty pointer", index);

    tsize = 0;
    NSGetSizeAndAlignment(dp->encoding, &tsize, NULL);

    ioffset = tsize * index;

    if (ioffset < 0) ioffset += dp->allocated_size;
    if (ioffset < 0) rb_raise(rb_eIndexError, "index %ld too small for pointer", index);

    offset = (size_t)ioffset;

    if (offset + tsize > dp->allocated_size) rb_raise(rb_eIndexError, "index %ld too big for pointer", index);

    rb_objc_convert_to_objc(rb_val, &(dp->cptr), offset, dp->encoding);

    return rb_val;
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

VALUE
rb_objc_ptr_at(VALUE rb_val, long index) {
  struct rb_objc_ptr *dp;
  VALUE val;
  size_t tsize;
  size_t offset;
  long ioffset;
  
  dp = (struct rb_objc_ptr*)DATA_PTR(rb_val);

  if (dp->allocated_size == 0) return Qnil;
  if (dp->encoding == NULL) return Qnil;

  tsize = 0;
  NSGetSizeAndAlignment(dp->encoding, &tsize, NULL);

  if (tsize == 0) return Qnil;
  
  ioffset = tsize * index;

  if (ioffset < 0) ioffset += dp->allocated_size;
  if (ioffset < 0) return Qnil;

  offset = (size_t)ioffset;
  
  if (offset + tsize > dp->allocated_size) return Qnil;

  rb_objc_convert_to_rb(dp->cptr, offset, dp->encoding, &val);

  return val;
}

VALUE
rb_objc_ptr_slice(VALUE rb_val, long index, long length)
{
  struct rb_objc_ptr *dp;
  VALUE rb_array;
  VALUE rb_elt;
  size_t tsize;
  size_t offset;
  long ioffset;

  if (length < 0) return Qnil;

  dp = (struct rb_objc_ptr*)DATA_PTR(rb_val);

  if (dp->allocated_size == 0) return Qnil;
  if (dp->encoding == NULL) return Qnil;

  tsize = 0;
  NSGetSizeAndAlignment(dp->encoding, &tsize, NULL);

  if (tsize == 0) return Qnil;
  
  ioffset = tsize * index;
  
  if (ioffset < 0) ioffset += dp->allocated_size;
  if (ioffset < 0) return Qnil;

  offset = (size_t)ioffset;
  
  if (offset + tsize > dp->allocated_size) return Qnil;

  rb_array = rb_ary_new();

  while(length-- > 0 && offset < dp->allocated_size) {
    rb_objc_convert_to_rb(dp->cptr, offset, dp->encoding, &rb_elt);
    rb_ary_push(rb_array, rb_elt);

    offset += tsize;
  }

  return rb_array;
}

void
rb_objc_ptr_ref(VALUE rb_val, void **data)
{
  struct rb_objc_ptr *dp;

  dp = (struct rb_objc_ptr*)DATA_PTR(rb_val);

  *(void**)data = &(dp->cptr);
}
