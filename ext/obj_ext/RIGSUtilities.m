/* RIGSUtilities.m - Utilities to add classes and methods 
   in the Objective-C runtime, at runtime.

   Written by:  Ryan Krug <keegnotrub@icloud.com>
   Date: July 2023

   It was partially derived by: encoding.c
   Encoding of types for Objective C.
   Copyright (C) 1993, 1995, 1996, 1997, 1998, 2000, 2002
   Free Software Foundation, Inc.
   Contributed by Kresten Krab Thorup
   Bitfield support by Ovidiu Predescu

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

#import "RIGSUtilities.h"

SEL
rb_objc_method_to_sel(const char* name, int argc)
{
  char *selName;
  int nbArgs;
  size_t i;
  size_t length;
  
  length = strlen(name);
  selName = alloca(sizeof(char) * (length + 2));
  nbArgs = 0;
  
  for (i=0;i<length;i++) {
    if (name[i] == '_') {
      selName[i] = ':';
      nbArgs++;
    }
    else {
      selName[i] = name[i];
    }
  }

  if (argc > nbArgs) {
    selName[i++] = ':';
    nbArgs++;
  }
  selName[i++] = '\0';

  if (argc < nbArgs) {
    return NULL;
  }
  return sel_getUid(selName);
}

char *
rb_objc_sel_to_method(SEL sel)
{
  const char *selName;
  char *name;
  size_t i;
  size_t length;

  selName = sel_getName(sel);
  length = strlen(selName);
  name = malloc(sizeof(char) * (length + 1));

  for (i=0;i<length;i++) {
    if (selName[i] == '_') {
      free(name);
      return NULL;
    }
    else if (selName[i] == ':') {
      if (i == length - 1) break;
      name[i] = '_';
    }
    else {
      name[i] = selName[i];
    }
  }
  
  name[i++] = '\0';
  
  return name;
}

char *
rb_objc_sel_to_alias(SEL sel)
{
  const char *selName;
  char *name;
  char *alias;
  size_t i;
  size_t length;

  if (sel_isEqual(sel, @selector(objectAtIndexedSubscript:)) ||
      sel_isEqual(sel, @selector(objectForKeyedSubscript:))) {
    name = malloc(sizeof(char) * 3);
    alias = name;
    *name++ = '[';
    *name++ = ']';
    *name++ = '\0';
    return alias;
  }

  selName = sel_getName(sel);
  length = strlen(selName);

  if (length > 3 &&
      selName[0] == 'i' &&
      selName[1] == 's' &&
      selName[2] == toupper(selName[2]) &&
      selName[length - 1] != ':') {
    name = malloc(sizeof(char) * (length + 1));
    alias = name;
    *name++ = selName[3] == toupper(selName[3]) ?
      selName[2] :
      tolower(selName[2]);
    for (i=3;i<length;i++) {
      if (selName[i] == ':' || selName[i] == '_') {
        free(alias);
        return NULL;
      }
      *name++ = selName[i];
    }
    *name++ = '?';
    *name++ = '\0';
    return alias;
  }
  else if (length > 4 &&
           selName[0] == 's' &&
           selName[1] == 'e' &&
           selName[2] == 't' &&
           selName[3] == toupper(selName[3]) &&
           selName[length - 1] == ':') {
    if (length > 6 &&
        selName[3] == 'W' &&
        selName[4] == 'i' &&
        selName[5] == 't' &&
        selName[6] == 'h') {
      // + NS{Mutable}Set setWith[Array,Object,etc]
      return NULL;
    }
    if (length > 6 &&
        selName[3] == 'B' &&
        selName[4] == 'y' &&
        selName[5] == 'A' &&
        selName[6] == 'd') {
      // - NS{Mutable}Set setByAdding[Object,Objects,etc]
      return NULL;
    }
    name = malloc(sizeof(char) * (length + 1));
    alias = name;
    *name++ = selName[4] == toupper(selName[4]) ?
      selName[3] :
      tolower(selName[3]);
    for (i=4;i<length-1;i++) {
      if (selName[i] == ':' || selName[i] == '_') {
        free(alias);
        return NULL;
      }
      *name++ = selName[i];
    }
    *name++ = '=';
    *name++ = '\0';
    return alias;
  }
  
  return NULL;
}


unsigned long
rb_objc_hash(const char* value)
{
  char keyChar;
  unsigned long hash = HASH_SEED;
  
  while ((keyChar = *value++)) {
    hash = ((hash << HASH_BITSHIFT) + hash) + keyChar;
  }

  return hash;
}


inline const char *
objc_skip_type_qualifiers(const char *type)
{
  while (*type == _C_CONST
         || *type == _C_IN
         || *type == _C_INOUT
         || *type == _C_OUT
         || *type == _C_BYCOPY
         || *type == _C_BYREF
         || *type == _C_ONEWAY)
    {
      type += 1;
    }
  return type;
}

const char *
objc_skip_typespec(const char *type)
{
  /* Skip the variable name if any */
  if (*type == '"')
    {
      for (type++; *type++ != '"';)
        /* do nothing */;
    }

  type = objc_skip_type_qualifiers(type);

  switch (*type) {

  case _C_ID:
    /* An id may be annotated by the actual type if it is known
       with the @"ClassName" syntax */

    if (*++type != '"')
      return type;
    else
      {
        while (*++type != '"')
          /* do nothing */;
        return type + 1;
      }

    /* The following are one character type codes */
  case _C_CLASS:
  case _C_SEL:
  case _C_CHR:
  case _C_UCHR:
  case _C_CHARPTR:
  case _C_ATOM:
  case _C_SHT:
  case _C_USHT:
  case _C_INT:
  case _C_UINT:
  case _C_LNG:
  case _C_ULNG:
  case _C_LNG_LNG:
  case _C_ULNG_LNG:
  case _C_FLT:
  case _C_DBL:
  case _C_VOID:
  case _C_UNDEF:
    return ++type;
    break;

  case _C_ARY_B:
    /* skip digits, typespec and closing ']' */

    while (isdigit((unsigned char)*++type))
      /* do nothing */;
    type = objc_skip_typespec(type);
    if (*type == _C_ARY_E)
      return ++type;
    else
      {
        return 0;
      }

  case _C_BFLD:
    /* The new encoding of bitfields is: b 'position' 'type' 'size' */
    while (isdigit((unsigned char)*++type))
      /* skip position */;
    while (isdigit((unsigned char)*++type))
      /* skip type and size */;
    return type;

  case _C_STRUCT_B:
    /* skip name, and elements until closing '}'  */

    while (*type != _C_STRUCT_E && *type++ != '=')
      /* do nothing */;
    while (*type != _C_STRUCT_E)
      {
        type = objc_skip_typespec(type);
      }
    return ++type;

  case _C_UNION_B:
    /* skip name, and elements until closing ')'  */

    while (*type != _C_UNION_E && *type++ != '=')
      /* do nothing */;
    while (*type != _C_UNION_E)
      {
        type = objc_skip_typespec(type);
      }
    return ++type;

  case _C_PTR:
    /* Just skip the following typespec */

    return objc_skip_typespec(++type);

  default:
    {
      return 0;
    }
  }
}


inline const char *
objc_skip_offset(const char *type)
{
  if (*type == '+')
    type++;
  while (isdigit((unsigned char) *++type))
    /* do nothing */;
  return type;
}

const char *
objc_skip_argspec(const char *type)
{
  type = objc_skip_typespec(type);
  type = objc_skip_offset(type);
  return type;
}
