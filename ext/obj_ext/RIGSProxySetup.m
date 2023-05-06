/* RIGSProxySetup.m - Tools to build `fake` ObjC classes delivering 
   messages to Ruby objects (they are called Proxy classes in RIGS)

   $Id$

   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Laurent Julliard (inspired from Nicola Pero JIGSProxySetup.m)
   Date: Aug 2001 
   
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

/* FIXME
   For the moment this is rather simple. All Ruby methods are declared as
   having @@:@@... as a signature (meaning it returns an id, receiver is an 
   object and all args are objects as wel.... We should really have a way to 
   get the real signature from Ruby which is only possible if it si given by
   the user because Ruby being a purely dynamic scripting language it has
   no notion of signature.

   We should also have a table to cache the mapped Ruby classes and methods
   as in JIGS where we keep a pointer on the class and method VALUE as well
   as number of arguments,etc...
*/

#include <Foundation/NSString.h>

#include <ruby.h>
#undef _ 
#undef __ 
/* must undefine because it conflicts with a macro with 
   the same name included by Foundation.h in ObjcRuntimeUtilities.h */
#include "ObjcRuntimeUtilities.h"
#include <objc/runtime.h>

#include "RIGS.h"
#include "RIGSCore.h"
#include "RIGSProxyIMP.h"
#include "RIGSProxySetup.h"
#include "RIGSSelectorMapping.h"

/* gets Ruby method arity (number of arguments) */
int _RIGS_ruby_method_arity(const char *rb_class_name, const char *rb_mth_name) 
{
    NSString *rb_eval_buf;
    
    // get the Ruby method arity (number of arguments)
    // Unfortunately the Ruby method_arity function is not visible
    // from outside so must eval Ruby code
    rb_eval_buf = [NSString stringWithFormat: @"%s.new.method(\"%s\").arity", 
                            rb_class_name,  rb_mth_name];
    return (FIX2INT(rb_eval_string([rb_eval_buf cString])));
}

/*
 * Register a new Ruby  class (and all its parent classes)
 * 
 * This method inspects the list of Ruby class methods using the Ruby
 * Introspection facility, and creates corresponding 'fake' ObjC methods
 * to mirror the Ruby ones.  
 *
 * Return nil if something goes wrong or the Objc class identifier if 
 * it goes ok.
 *
 * class is passed as its Ruby VALUE
 *
 * This was for JIGS only ->
 * isRootClass must be 'YES' only for java.lang.Object.  This class
 * is then created with an additional ivar, called 'realObject'.
 */

Class _RIGS_register_ruby_class (VALUE rb_class)
{
  @autoreleasepool {
  int i;
  int count;
  VALUE listOption;
  int nbArgs;
  VALUE rb_mth_ary;
  Class superClass;
  Class class;
  char *rb_mth_name;
  NSString *objcMthName;
  const char *signature;
  char objcTypes[128];
  char *rb_class_name = NULL;
  NSString *className;
  BOOL guessed;
  IMP mthIMP;



  // If this class has already been registered then
  // do nothing
  
  // Check that this is a Ruby Class. 
  if (TYPE(rb_class) == T_CLASS) {
      // Yes it is. So get the class name 
      rb_class_name = rb_class2name(rb_class);
  } else {
      // Nope! give up
      NSLog(@"Trying to register unknown Ruby class: %s",rb_class_name);
      return nil;
  }

  NSDebugLog (@"Registering Ruby class %s with the objective-C runtime", 
              rb_class_name);

  // If this class has already been registered with ObjC then
  // do nothing
  className = [NSString stringWithCString: rb_class_name];
  
  if ( (class = NSClassFromString(className)) ) {
      NSDebugLog(@"Class already registered with ObjC: %@",className);
      return class;
  }
  
  // Create the Objective-C proxy class. 
  // Make things simple for the moment and inherit from NSObject
  superClass = NSClassFromString(@"RIGSWrapObject");
  class = objc_allocateClassPair (superClass, rb_class_name, 0);
  if (class == nil) {
      NSLog(@"Could not allocate class pair with ObjC: %s",rb_class_name);
      return nil; 
  }
  
  // NB: If something in the next part throws an exception, 
  // we are left with an unfinished proxy class !


  /*
   * Instance Methods
   */


  // Get instance method list. Pass no argument to function to
  // eliminate ancestor's method from the list.
  listOption = INT2FIX(0);
  rb_mth_ary = rb_class_instance_methods(0,&listOption,rb_class);
  // number of instance methods in this class
  count = RARRAY_LEN(RARRAY(rb_mth_ary));
  NSDebugLog(@"This Ruby class has %d instance methods",count);

  // Prepare the instance methods list
  if (count > 0) {

      for (i=0;i<count;i++) {

        // get the Ruby method arity (number of arguments)
        VALUE entry = rb_ary_entry(rb_mth_ary, (long)i);
        rb_mth_name = rb_string_value_cstr(&entry);
        
        nbArgs = _RIGS_ruby_method_arity(rb_class_name, rb_mth_name);
      
 
        objcMthName = SelectorStringFromRubyName(rb_mth_name, nbArgs);

        NSDebugLog(@"Ruby method %s has %d arguments",rb_mth_name,nbArgs);

        if (nbArgs < 0) {
          // skip over method with variable number of arguments
          //NSLog(@"**WARNING** Don't know how to handle method with variable number of args : %s",rb_mth_name);
          //continue;
	  // HACK: This is probably not the "Right Way" to fix the segfault 
	  // bug, but it seems to work.
	  nbArgs *= -1;
        }
        
        // Build the method ObjC types and then the full signature
        guessed = _RIGS_build_objc_types(rb_class, rb_mth_name, '\0', nbArgs, objcTypes);
        signature = objc_build_runtime_signature(objcTypes); 
        
        NSDebugLog(@"Inserting ObjC method %@ with signature '%s'",objcMthName,signature);


        switch (*objcTypes)
          {
          case _C_ID:
            mthIMP = (IMP) _RIGS_id_IMP_RubyMethod;
            break;
          case _C_SEL:
            mthIMP = (IMP) _RIGS_SEL_IMP_RubyMethod;
            break;
          case _C_CLASS:
            mthIMP = (IMP) _RIGS_id_IMP_RubyMethod;
            break;
          case _C_VOID:
            mthIMP = (IMP) _RIGS_void_IMP_RubyMethod;
            break;
          case _C_CHARPTR:
            mthIMP = (IMP) _RIGS_char_ptr_IMP_RubyMethod;
            break;
           case _C_CHR:
            mthIMP = (IMP) _RIGS_char_IMP_RubyMethod;
            break;
          case _C_UCHR:
            mthIMP = (IMP) _RIGS_unsigned_char_IMP_RubyMethod;
            break;
          case _C_SHT:
            mthIMP = (IMP) _RIGS_short_IMP_RubyMethod;
            break;
          case _C_USHT:
            mthIMP = (IMP) _RIGS_unsigned_short_IMP_RubyMethod;
            break;
          case _C_INT:
            mthIMP = (IMP) _RIGS_int_IMP_RubyMethod;
            break;
          case _C_UINT:
            mthIMP = (IMP) _RIGS_unsigned_int_IMP_RubyMethod;
            break;
          case _C_LNG:
            mthIMP = (IMP) _RIGS_long_IMP_RubyMethod;
            break;
          case _C_ULNG:
            mthIMP = (IMP) _RIGS_unsigned_long_IMP_RubyMethod;
            break;
          case _C_FLT:
            mthIMP = (IMP) _RIGS_float_IMP_RubyMethod;
            break;
          case _C_DBL:
            mthIMP = (IMP) _RIGS_double_IMP_RubyMethod;
            break;
          default:
              mthIMP = (IMP) NULL;
            break;
            
          }
        
        if (mthIMP == (IMP)NULL)
            {
                NSString *reason = 
                    [NSString stringWithFormat:@"Unrecognized return type '%c' to IMP for ruby method %s",objcTypes[0],rb_mth_name];
                
                [NSException raise: @"Ruby Interface Error" format:reason];
            }


        class_addMethod(class, sel_registerName([objcMthName cString]), mthIMP, signature);
      } /*end for method loop */
  }
  
  objc_registerClassPair(class);

  return class;
  }
}


VALUE _RIGS_register_ruby_class_from_ruby (VALUE self, VALUE rb_class)
{

    return (_RIGS_register_ruby_class(rb_class) ? Qtrue : Qfalse);
  
}

/* IMPORTANT REMARK

   Ruby like most dynamic scripting language has no notion of what
   a method signature is.  So when a ObjC proxy class is created to
   "mirror" a class that is actually implemented in Ruby with have 2
   options to define the appropriate method signature for the ObjC
   proxy methods:
   1 - On Ruby side there is a hash table stored as a class variable
        (@@objc_types) which contains the ObjC Types string for all
        the methods of the class
   2 - If nothing is speicified then we assume a "@@:@...@" types
        by defaut. It is a method returning an object and taking all
        its arguments as object.

   In most cases the default option will work especially because we try
   and guess the ObjC return value based on the VALUE type returned
   by Ruby. However if either the return value or one of the argument
   has a type which is doesn't have the same size as an id (like double, char
   or short on 32 bits architecture) then you have to define the ObjC types string 
   explicitely or your data will be corrupted (best case) or a SEG FAULT
   will happen.

   The guessing procedure is relatively conservative and an Exception will
   be raised in case guessing is too dangerous.

   FIXME!
   There is a 3rd option that we don't use yet here. When the ObjC types string
   is not specified we could try and see if there is already an existing ObjC
   selector and use it.
*/

BOOL _RIGS_build_objc_types(VALUE rb_class, const char *rb_mth_name, 
                            const char retValueType, int nbArgs, char *objcTypes)
{
  VALUE rb_objc_types;
  int j;
  BOOL found = NO;
  ID rb_ID;

  // Check whether the signatures was specified on the Ruby side
  // (@@objc_signatures hash table with method names as key and
  // ObjC types as value)
  rb_ID = rb_intern("@@objc_types");
  if ( rb_cvar_defined(rb_class, rb_ID) ) {

    rb_objc_types = rb_cvar_get(rb_class, rb_ID);

    if (TYPE(rb_objc_types) == T_HASH) {

      VALUE key = rb_str_new2(rb_mth_name);
      VALUE value = rb_hash_aref(rb_objc_types, key);
      if (!NIL_P(value)) {
        strcpy(objcTypes, rb_string_value_cstr(&value));
        NSDebugLog(@"ObjC Types  '%s' found in Ruby for method %s",
                   objcTypes, rb_mth_name);
        found = YES;
      }
    }
  }
 
      
  if (!found) {
    
    // Nothing given on the Ruby side so...
    // Assume that we always return something (an id) and add as many
    // arguments of type object as needed by the arity of the Ruby method
 
    strcpy(objcTypes,"@@:");
    for (j=0;j<nbArgs;j++) {
      strcat(objcTypes,"@");
    }
    // If the type of the return value is given as an argument then override
    // the default _C_ID ('@')
    if (retValueType) {
         objcTypes[0] = retValueType;
     }
     
    NSDebugLog(@"ObjC types for method '%s' not found in Ruby. Assuming  '%s' ",
               rb_mth_name, objcTypes);
  }

  return found;
  
}
