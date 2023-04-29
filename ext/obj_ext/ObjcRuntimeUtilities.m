/* ObjcRuntimeUtilities.m - Utilities to add classes and methods 
   in the Objective-C runtime, at runtime.

   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000
   
   This file is part of the GNUstep Java Interface Library.

   It was partially derived by: 

   --
   gg_class.m - interface between guile and GNUstep
   Copyright (C) 1998 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: September 1998

   This file is part of the GNUstep-Guile Library.

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


#include "ObjcRuntimeUtilities.h"
#include <string.h>

/* For macOS 11 - objc/runtime.h doesn't define these */
#define _C_CONST       'r'
#define _C_IN          'n'
#define _C_INOUT       'N'
#define _C_OUT         'o'
#define _C_BYCOPY      'O'
#define _C_BYREF       'R'
#define _C_ONEWAY      'V'

const char *ObjcUtilities_build_runtime_Objc_signature (const char 
							       *types)
{
  NSMethodSignature *sig;
  
  sig = [NSMethodSignature signatureWithObjCTypes: types];
  
  NSMutableString	*str;
  NSUInteger		count;
  NSUInteger		index;
  
  str = [NSMutableString stringWithCapacity: 128];
  [str appendFormat: @"%s", [sig methodReturnType]];
  count = [sig numberOfArguments];
  for (index = 0; index < count; index++)
    {
      [str appendFormat: @"%s", [sig getArgumentTypeAtIndex: index]];
    }
  return [str UTF8String];  
}

inline const char *
objc_skip_type_qualifiers (const char *type)
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
objc_skip_typespec (const char *type)
{
  /* Skip the variable name if any */
  if (*type == '"')
    {
      for (type++; *type++ != '"';)
	/* do nothing */;
    }

  type = objc_skip_type_qualifiers (type);

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

    while (isdigit ((unsigned char)*++type))
      ;
    type = objc_skip_typespec (type);
    if (*type == _C_ARY_E)
      return ++type;
    else
      {
	return 0;
      }

  case _C_BFLD:
    /* The new encoding of bitfields is: b 'position' 'type' 'size' */
    while (isdigit ((unsigned char)*++type))
      ;	/* skip position */
    while (isdigit ((unsigned char)*++type))
      ;	/* skip type and size */
    return type;

  case _C_STRUCT_B:
    /* skip name, and elements until closing '}'  */

    while (*type != _C_STRUCT_E && *type++ != '=')
      ;
    while (*type != _C_STRUCT_E)
      {
	type = objc_skip_typespec (type);
      }
    return ++type;

  case _C_UNION_B:
    /* skip name, and elements until closing ')'  */

    while (*type != _C_UNION_E && *type++ != '=')
      ;
    while (*type != _C_UNION_E)
      {
	type = objc_skip_typespec (type);
      }
    return ++type;

  case _C_PTR:
    /* Just skip the following typespec */

    return objc_skip_typespec (++type);

  default:
    {
      return 0;
    }
  }
}


inline const char *
objc_skip_offset (const char *type)
{
  if (*type == '+')
    type++;
  while (isdigit ((unsigned char) *++type))
    ;
  return type;
}

const char *
objc_skip_argspec (const char *type)
{
  type = objc_skip_typespec (type);
  type = objc_skip_offset (type);
  return type;
}

