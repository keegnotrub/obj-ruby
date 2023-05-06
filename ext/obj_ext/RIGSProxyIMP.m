/* JIGSProxyIMP.m - Actual forwarding functions to call Ruby method
    from  Objective C.

   $Id$

   Copyright (C) 2001 Free Software Foundation, Inc.

   Written by:  Laurent Julliard
   Date: Aug 2001 (inspired from Nicola Pero JIGSProxyImp.m)
   
   This file is part of the GNUstep Ruby  Interface Library.

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

#include <objc/objc-api.h>
#include <objc/runtime.h>
//#include <objc/thr.h>

#include "RIGS.h"
#include "RIGSCore.h"
#include "ObjcRuntimeUtilities.h"
#include "RIGSProxyIMP.h"
#include "RIGSProxySetup.h"
#include "RIGSWrapObject.h"
#include "RIGSSelectorMapping.h"

#define COMMON_VAR_DECLARATION \
  const char *type; \
  const char *return_type; \
  Class class = (Class)(object_getClass(rcv));  \
  const char *className; \
  const char *rb_mth_name; \
  int i; \
  int nbArgs; \
  va_list ap; \
  VALUE rb_class = Qnil; \
  VALUE rb_rcv = Qnil; \
  VALUE rb_ret; \
  VALUE *rb_args; \
  char objcTypes[128]; \
  BOOL okydoky, guessed;

#define ENTER(IMPname) \
  NSDebugLog(@"Entering%s...",#IMPname);

#define GET_CLASSNAME \
    className = [NSStringFromClass(class) cString];

#define GET_RUBY_METHOD_NAME \
    rb_mth_name = [RubyNameFromSelector(sel) cString]; \
    NSDebugLog(@"Sending message %s to object of Class %s...", rb_mth_name, className);

#define GET_AND_CHECK_RECEIVER \
  if ( [rcv isKindOfClass: [RIGSWrapObject class]] ) { \
      rb_rcv = (VALUE)[rcv getRubyObject]; \
      rb_class = CLASS_OF(rb_rcv); \
  } else {  \
      NSLog(@"Don't know how to send method %s to object of class %s",\
            rb_mth_name, className);\
      return objcRet;\
  }

#define GET_AND_CHECK_RECEIVER_NO_RETURN \
  if ( [rcv isKindOfClass: [RIGSWrapObject class]] ) { \
      rb_rcv = (VALUE)[rcv getRubyObject]; \
      rb_class = CLASS_OF(rb_rcv); \
  } else {  \
      NSLog(@"Don't know how to send method %s to object of class %s",\
            rb_mth_name, className);\
  }


#define GET_NUMBER_OF_ARGUMENTS \
  nbArgs = _RIGS_ruby_method_arity(className, rb_mth_name);


#define BUILD_METHOD_SIGNATURE(retValueType) \
  guessed = _RIGS_build_objc_types(rb_class, rb_mth_name, retValueType, nbArgs, objcTypes); \
 \
  type = objc_build_runtime_signature(objcTypes); \
  return_type = type; \
  NSDebugLog(@"Generated signature '%s'", type); \

/*
 * Macros to process the whole list of arguments
 */

#define INIT_PROCESS_ARGS              \
      type = objc_skip_argspec (type); /* skip return type	*/ \
      type = objc_skip_argspec (type); /* skip receiver */ \
      type = objc_skip_argspec (type); /* skip selector */ \
                                       \
      va_start (ap, sel);              \
      i = 0;

#define DO_PROCESS_ARGS                                \
      while (*type != '\0') {                           \
          NSUInteger size;                              \
          NSGetSizeAndAlignment(type, &size, NULL);    \
	      { \
          struct dummy { struct { } __empty_; char val[]; };  \
          struct dummy *block = malloc(sizeof *block + size * sizeof(char)); \
              int offset = 0; \
                *block= va_arg(ap, struct dummy); \
          okydoky = rb_objc_convert_to_rb((void *) block, offset, type, &rb_args[i], NO); \
          free(block); \
              } \
          type = objc_skip_argspec (type); \
	  i++; }                               

#define END_PROCESS_ARGS va_end(ap);

#define PROCESS_ARGS                              \
  rb_args = alloca (nbArgs * sizeof (VALUE)); \
                                                  \
  if (nbArgs > 0) {                         \
    INIT_PROCESS_ARGS                             \
    DO_PROCESS_ARGS                               \
    END_PROCESS_ARGS }
  
#define RUN_RUBY_METHOD \
  rb_ret = rb_funcall2(rb_rcv, rb_intern(rb_mth_name), nbArgs, rb_args); \
  NSDebugLog(@"Ruby value returned to this IMP : 0x%lx", rb_ret);

#define CONVERT_RETURN_VALUE_TO_OBJC \
  { int offset = 0; \
    okydoky = rb_objc_convert_to_objc(rb_ret, (void*)&objcRet, offset, return_type); \
   }

#define LEAVE(IMPname) \
  NSDebugLog(@"Leaving %s",#IMPname);

#define RETURN_TO_OBJC \
  return objcRet;
  




// This IMP is a bit special because it handles implementation
// of ObjC methods the really return an id and all others for which
// no objC Types string was specified in Ruby and we need to make
// a best guess
id _RIGS_id_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    char final_return_type;
    id objcRet = nil;
    
    ENTER(_RIGS_id_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_ID);
  
    PROCESS_ARGS;
    RUN_RUBY_METHOD;

    // return the value to ObjC
    // if the method signature was initially "guessed" because there was
    // nothing in the @@objc_types Class variable in Ruby then try to
    // be more accurate by looking at the value type returned by Ruby.
    // Else simply use the return type provided in the initial signature
    if (guessed) { 

        final_return_type = _RIGS_guess_objc_return_type(rb_ret);

        // If return type could not be guessed or was too risky to guess
        // then raise an exception
        if (final_return_type) {
 
            // FIXME !!! Here we dangerously patch the first character of
            // method return type (don't know if this is really portable and/or
            // safe
           *(char *)return_type = final_return_type;

        } else {
            
            NSString *reason = 
                [NSString stringWithFormat:@"Too risky to guess Objc method return type '@' for ruby type 0x%02x (method '%s'). Please give it explicitely in the @@objc_types class variable",TYPE(rb_ret),rb_mth_name];
            
            [NSException raise: @"Ruby Interface Error" format:reason];
        }

    }
    
    CONVERT_RETURN_VALUE_TO_OBJC;
    
    LEAVE(_RIGS_id_IMP_RubyMethod);
    RETURN_TO_OBJC;
  
}

Class _RIGS_Class_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    Class objcRet = NULL;

    
    ENTER(_RIGS_Class_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_CLASS);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_Class_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

SEL _RIGS_SEL_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    SEL objcRet = NULL;

    
    ENTER(_RIGS_SEL_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_SEL);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_SEL_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

void _RIGS_void_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION

    ENTER(_RIGS_void_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER_NO_RETURN;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_VOID);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    LEAVE(_RIGS_void_IMP_RubyMethod);
}

char *_RIGS_char_ptr_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    char * objcRet = NULL;

    
    ENTER(_RIGS_char_ptr_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_CHARPTR);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_char_ptr_IMP_RubyMethod);
    RETURN_TO_OBJC;
}


char _RIGS_char_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    char objcRet = '\0';

    
    ENTER(_RIGS_char_IMP_RubyMethod);

    // Get class name
    GET_CLASSNAME;

    // Get Selector name
    GET_RUBY_METHOD_NAME;

    /* For now we do not know how to handle this  if the method
           call is sent to anything else than  a Ruby Wrapped Object or
           one of its subclass.. 
           We do not know how to handle  ruby method call sent to
           native ObjC objects  */
    GET_AND_CHECK_RECEIVER;

    // get number of args
    // FIXME: This number should be stored somewhere when the
    // ObjC proxy class is registered because it takes time to compute
    // it again and again.
    GET_NUMBER_OF_ARGUMENTS;
  
  // Build the ObjC types string
    BUILD_METHOD_SIGNATURE(_C_CHR);
 
   
    // Process Arguments
    // - Allocate a table of Ruby VALUEs to pass as a list of arguments
    // - transform each argument one after the other
    PROCESS_ARGS;
  
  
    // call the ruby method
    RUN_RUBY_METHOD;

    // convert the value returned by Ruby and return it to ObjC caller
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_char_IMP_RubyMethod);
    RETURN_TO_OBJC;
}


unsigned char
_RIGS_unsigned_char_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    unsigned char objcRet = 0;

    
    ENTER(_RIGS_unsigned_char_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_UCHR);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_unsigned_char_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

short
_RIGS_short_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    short objcRet = 0;

    
    ENTER(_RIGS_short_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_SHT);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_short_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

unsigned short
_RIGS_unsigned_short_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    unsigned short objcRet = 0;

    
    ENTER(_RIGS_unsigned_short_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_USHT);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_unsigned_short_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

int
_RIGS_int_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    int objcRet = 0;

    
    ENTER(_RIGS_int_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_INT);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_int_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

unsigned int
_RIGS_unsigned_int_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    unsigned int objcRet = 0;

    
    ENTER(_RIGS_unsigned_int_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_UINT);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_unsigned_int_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

long
_RIGS_long_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    long objcRet = 0;

    
    ENTER(_RIGS_long_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_LNG);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_long_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

unsigned long
_RIGS_unsigned_long_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    unsigned long objcRet = 0;

    
    ENTER(_RIGS_unsigned_long_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_ULNG);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_unsigned_long_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

float
_RIGS_float_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    float objcRet = 0;

    
    ENTER(_RIGS_float_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_FLT);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_float_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

double
_RIGS_double_IMP_RubyMethod (id rcv, SEL sel, ...)
{
    COMMON_VAR_DECLARATION
    double objcRet = 0;

    
    ENTER(_RIGS_double_IMP_RubyMethod);
    GET_CLASSNAME;
    GET_RUBY_METHOD_NAME;
    GET_AND_CHECK_RECEIVER;
    GET_NUMBER_OF_ARGUMENTS;
    BUILD_METHOD_SIGNATURE(_C_DBL);
    PROCESS_ARGS;
    RUN_RUBY_METHOD;
    CONVERT_RETURN_VALUE_TO_OBJC;
    LEAVE(_RIGS_double_IMP_RubyMethod);
    RETURN_TO_OBJC;
}

/* Try and guess the ObjC return type of a method from the
  value return by Ruby -- VERY RISKY BUSINESS !!! */
unsigned char _RIGS_guess_objc_return_type(VALUE rb_val)
{

  switch (TYPE(rb_val))
    {
    
    case T_CLASS:
    case T_OBJECT:
    case T_NIL:
      return _C_ID;
      
    case T_FIXNUM:
    case T_BIGNUM:
      // This one is very risky.... ObjC could be waiting for short
      // or unsigned short or (unsigned) long for BIGNUM,...
      return _C_INT;
      break;

    case T_TRUE:
    case T_FALSE:
      return _C_UCHR;
      break;

    case T_FLOAT:
      // This one is risky as well... ObjC could be expecting a double...
      return _C_FLT;
      break;

    default:
      return 0;
      break;
    }
}
