/* RIGS.m - Ruby Interface to GNUstep

   $Id$

   Copyright (C) 2001 Free Software Foundation, Inc.

   Written by:  Laurent Julliard <laurent@julliard-online.org>
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


   History:
     - Original code from Avi Bryant's cupertino test project <avi@beta4.com>
     - Code patiently improved and augmented 
         by Laurent Julliard <laurent@julliard-online.org>

*/

#include <objc/objc-class.h>
#define ROUND(V, A) \
  ({ typeof(V) __v=(V); typeof(A) __a=(A); \
     __a*((__v+__a-1)/__a); })


/* Do not include the whole <Foundation/Foundation.h> to avoid
   conflict with ID definition in ruby.h for MACOSX */
#include <Foundation/NSObject.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSException.h>
#include <Foundation/NSInvocation.h>
#include <Foundation/NSMapTable.h>
#include <Foundation/NSSet.h>
#include <Foundation/NSProcessInfo.h>
#include <Foundation/NSBundle.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSMethodSignature.h>
#include <Foundation/NSString.h>
#include <Foundation/NSData.h>
#include <Foundation/NSValue.h>

#include <AppKit/NSApplication.h>

#include "RIGS.h"
#include "RIGSCore.h"
#include "ObjcRuntimeUtilities.h"
#include "RIGSWrapObject.h"
#include "RIGSSelectorMapping.h"
#include "RIGSProxySetup.h"
#include "RIGSNSApplication.h"
#include "RIGSNSDictionary.h"
#include "RIGSNSArray.h"
#include "RIGSNSString.h"
#include "RIGSNSNumber.h"

// Our own argc and argv rebuilt  from Ruby ARGV ($*)
char **ourargv;
int ourargc;
extern char** environ;

// Hash table  that maps known ObjC class to Ruby class VALUE
static NSMapTable *knownClasses = 0;

// Hash table that maps known ObjC objects to Ruby object VALUE
static NSMapTable *knownObjects = 0;

// Rigs Ruby module
static VALUE rb_mRigs;

/* Define a couple of macros to get/set Ruby CStruct objects 
    (CStruct class is the Ruby equivalent of the C structure */
   
#define RB_CSTRUCT_CLASS \
rb_const_get(rb_cObject, rb_intern("CStruct"))

#define RB_CSTRUCT_NEW() \
rb_class_new_instance(0,NULL, RB_CSTRUCT_CLASS)

#define RB_CSTRUCT_ENTRY(aCStruct, idx) \
rb_funcall(aCStruct, rb_intern("[]"), 1, INT2FIX(idx))

#define RB_CSTRUCT_PUSH(aCStruct, aValue) \
rb_funcall(aCStruct, rb_intern("push"), 1, aValue)

void
rb_objc_release(id objc_object) 
{
  NSDebugLog(@"Call to ObjC release on 0x%lx",objc_object);

  if (objc_object != nil) {
    @autoreleasepool {
    /* Use an autorelease pool here because both `repondsTo:' and
       `release' could autorelease objects. */

    NSMapRemove(knownObjects, (void*)objc_object);
    if ([objc_object respondsToSelector: @selector(release)])
      {
        [objc_object release];
      }
    }
  }
 
}


void
rb_objc_mark(VALUE rb_object) 
{
    // Doing nothing for the moment
    NSDebugLog(@"Call to ObjC marking on 0x%lx",rb_object);
}


/* 
    Normally new method has no arg in objective C. 
    If you want it to have arguments when using new from Ruby then
    override the new method from Ruby.  See NSSelector.rb for an example
*/
VALUE
rb_objc_new(int rigs_argc, VALUE *rigs_argv, VALUE rb_class)
{
    @autoreleasepool {
    id obj;
    VALUE new_rb_object;
   
    // get the class from the objc_class class variable now
    Class objc_class = (Class) NUM2LL(rb_iv_get(rb_class, "@objc_class"));

    // This object is not released on purpose. The Ruby garbage collector
    // will take care of deallocating it by calling rb_objc_release()

    obj  = [[objc_class alloc] init];
    new_rb_object = Data_Wrap_Struct(rb_class, 0, rb_objc_release, obj);
    NSMapInsertKnownAbsent(knownObjects, (void*)obj, (void*)new_rb_object);
    NSDebugLog(@"Creating new object of Class %@ (id = 0x%lx, VALUE = 0x%lx)",
               NSStringFromClass([objc_class class]), obj, new_rb_object);

    return new_rb_object;
    }
}

BOOL
rb_objc_convert_to_objc(VALUE rb_thing,void *data, int offset, const char *type)
{
    BOOL ret = YES;
    Class objcClass;
    NSString *msg;
    VALUE rb_class_val;
    int idx = 0;
    BOOL inStruct = NO;
  
 
    // If Ruby gave the NIL value then bypass all the rest
    // (FIXME?) Check if it should be handled differently depending
    //  on the ObjC type.
    if(NIL_P(rb_thing)) {
        *(id*)data = (id) nil;
        return YES;
    } 
  
  
    if (*type == _C_STRUCT_B) {
        inStruct = YES;
        while (*type != _C_STRUCT_E && *type++ != '=');
        if (*type == _C_STRUCT_E) {
            return YES;
        }
    }

    do {

        NSUInteger tsize;
        NSUInteger align;
        
        void	*where;
        VALUE	rb_val;

        type = objc_skip_type_qualifiers (type);
        
        NSGetSizeAndAlignment(type, &tsize, &align);
   
        offset = ROUND(offset, align);
        where = data + offset;
        
        offset += tsize;

        NSDebugLog(@"Converting Ruby value (0x%lx, type 0x%02lx) to ObjC value of type '%c' at target address 0x%lx)",
                   rb_thing, TYPE(rb_thing),*type,where);

        if (inStruct) {
            rb_val = RB_CSTRUCT_ENTRY(rb_thing,idx);
            idx++;
        } else {
            rb_val = rb_thing;
        }

        // All other cases
        switch (*type) {
      
        case _C_ID:
        case _C_CLASS:

            switch (TYPE(rb_val))
                {
                case T_DATA:
                    Data_Get_Struct(rb_val,id,* (id*)where);
          
                    /* Automatic conversion from string -- see below _C_SEL case
                       if ([ret class] == [NSSelector class]) {
                       ret = [ret getSEL];
                       NSDebugLog(@"Extracting ObjC SEL (0x%lx) from NSSelector object", ret);
                       } */
          
                    break;

                case T_SYMBOL:
                    *(NSString**)where = [NSString stringWithRubySymbol:rb_val];
                    break;
          
                case T_STRING:
                    *(NSString**)where = [NSString stringWithRubyString:rb_val];
                    break;
          
                case T_OBJECT:
                case T_CLASS:
                    /* Ruby sends a Ruby class or a ruby object. Automatically register
                                      an ObjC proxy class. It is very likely that we'll need it in the future
                                      (e.g. typical for setDelegate method call) */
                    rb_class_val = (TYPE(rb_val) == T_CLASS ? rb_val : CLASS_OF(rb_val));
                    NSDebugLog(@"Converting object of Ruby class: %s", rb_class2name(rb_class_val));
                    objcClass = _RIGS_register_ruby_class(rb_class_val);
                    *(id*)where = (id)[objcClass objectWithRubyObject: rb_val];
                    NSDebugLog(@"Wrapping Ruby Object of type: 0x%02x (ObjC object at 0x%lx)",TYPE(rb_val), *(id*)where);
                    break;
          
                case T_ARRAY:
                    *(NSArray**)where = [NSArray arrayWithRubyArray:rb_val];
                    break;
                    
                case T_HASH:
                    *(NSDictionary**)where = [NSDictionary dictionaryWithRubyHash:rb_val];
                    break;

                case T_FIXNUM:
                    *(NSNumber**)where = [NSNumber numberWithRubyFixnum:rb_val];
                    break;
                    
                case T_BIGNUM:
                    *(NSNumber**)where = [NSNumber numberWithRubyBignum:rb_val];
                    break;

                case T_FLOAT:
                    *(NSNumber**)where = [NSNumber numberWithRubyFloat:rb_val];
                    break;

                case T_FALSE:
                    *(BOOL*)where = NO;
                    break;

                case T_TRUE:
                    *(BOOL*)where = YES;
                    break;

                default:
                    ret = NO;
                    break;
                
                }
            break;

        case _C_SEL:
            if (TYPE(rb_val) == T_STRING) {
            
                *(SEL*)where = [NSSelector selectorWithRubyString:rb_val];
            
            } else if (TYPE(rb_val) == T_DATA) {

                // This is in case the selector is passed as an instance of NSSelector
                // which is a class the we have created
                id object;
                Data_Get_Struct(rb_val,id,object);
                if ([object isKindOfClass: [NSSelector class]]) {
                    *(SEL*)where = [object getSEL];
                } else {
                    ret = NO;
                }

            } else {
                ret = NO;
            }
            break;
 

        case _C_CHR:
            if ((TYPE(rb_val) == T_FIXNUM) || (TYPE(rb_val) == T_STRING)) 
                *(char*)where = (char) NUM2CHR(rb_val);
            else if (TYPE(rb_val) == T_TRUE)
                *(char*)where = YES;
            else if (TYPE(rb_val) == T_FALSE)
                *(char*)where = NO;
            else
                ret = NO;
            break;

        case _C_UCHR:
            if ( ((TYPE(rb_val) == T_FIXNUM) && FIX2INT(rb_val)>=0) ||
                 (TYPE(rb_val) == T_STRING)) 
                *(unsigned char*)where = (unsigned char) NUM2CHR(rb_val);
            else
                ret = NO;
            break;

        case _C_SHT:
            if (TYPE(rb_val) == T_FIXNUM) 
                if (FIX2INT(rb_val) <= SHRT_MAX || FIX2INT(rb_val) >= SHRT_MIN) 
                    *(short*)where = (short) FIX2INT(rb_val);
                else {
                    NSLog(@"*** Short overflow %d",FIX2INT(rb_val));
                    ret = NO;
                }        
            else
                ret = NO;
            break;

        case _C_USHT:
            if (TYPE(rb_val) == T_FIXNUM) 
                if (FIX2INT(rb_val) <= USHRT_MAX || FIX2INT(rb_val) >=0)
                    *(unsigned short*)where = (unsigned short) FIX2INT(rb_val);
                else {
                    NSLog(@"*** Unsigned Short overflow %d",FIX2INT(rb_val));
                    ret = NO;
                } else {
                    ret = NO;
                }
            break;

        case _C_INT:
            if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )
                *(int*)where = (int) NUM2INT(rb_val);
            else
                ret = NO;	  
            break;

        case _C_UINT:
            if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM)
                *(unsigned int*)where = (unsigned int) NUM2UINT(rb_val);
            else
                ret = NO;
            break;

        case _C_LNG:
            if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )
                *(long*)where = (long) NUM2LONG(rb_val);
            else
                ret = NO;	  	
            break;

        case _C_ULNG:
            if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )
                *(unsigned long*)where = (unsigned long) NUM2ULONG(rb_val);
            else
                ret = NO;	  	
            break;

        case _C_LNG_LNG:
            if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )
                *(long long*)where = (long long) NUM2LL(rb_val);
            else
                ret = NO;	  	
            break;

        case _C_ULNG_LNG:
            if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )              
                *(unsigned long long*)where = (unsigned long long) NUM2ULL(rb_val);
            else
                ret = NO;	  	
            break;

        case _C_FLT:
            if ( (TYPE(rb_val) == T_FLOAT) || 
                 (TYPE(rb_val) == T_FIXNUM) ||
                 (TYPE(rb_val) == T_BIGNUM) ) {

                // FIXME: possible overflow but don't know (yet) how to check it ??
                *(float*)where = (float) NUM2DBL(rb_val);
                NSDebugLog(@"Converting ruby value to float : %f", *(float*)where);
            }
            else
                ret = NO;	  	
            break;
	   

        case _C_DBL:
            if ( (TYPE(rb_val) == T_FLOAT) || 
                 (TYPE(rb_val) == T_FIXNUM) ||
                 (TYPE(rb_val) == T_BIGNUM) ) {
        
                // FIXME: possible overflow but don't know (yet) how to check it ??
                *(double*)where = (double) NUM2DBL(rb_val);
                NSDebugLog(@"Converting ruby value to double : %lf", *(double*)where);
            }
            else
                ret = NO;	  	
            break;

        case _C_CHARPTR:
            // Inspired from the Guile interface
            if (TYPE(rb_val) == T_STRING) {
            
                NSMutableData	*d;
                char		*s;
                int		l;
            
                s = rb_string_value_cstr(&rb_val);
                l = strlen(s)+1;
                d = [NSMutableData dataWithBytesNoCopy: s length: l freeWhenDone:NO];
                *(char**)where = (char*)[d mutableBytes];
            
            } else if (TYPE(rb_val) == T_DATA) {
                // I guess this is the right thing to do. Pass the
                // embedded ObjC as a blob
                Data_Get_Struct(rb_val,char* ,* (char**)where);
            } else {
                ret = NO;
            }
            break;
   

        case _C_PTR:
            // Inspired from the Guile interface. Same as char_ptr above
            if (TYPE(rb_val) == T_STRING) {
            
                NSMutableData	*d;
                char		*s;
                int		l;
            
                s = rb_string_value_cstr(&rb_val);
                l = strlen(s);
                d = [NSMutableData dataWithBytesNoCopy: s length: l freeWhenDone:NO];
                *(void**)where = (void*)[d mutableBytes];
            
            } else if (TYPE(rb_val) == T_DATA) {
                // I guess this is the right thing to do. Pass the
                // embedded ObjC as a blob
                Data_Get_Struct(rb_val,void* ,*(void**)where);
            } else {
                ret = NO;
            }
            break;


        case _C_STRUCT_B: 
          {
            // We are attacking a new embedded structure in a structure
            
            // The Ruby argument must be of type CStruct or a sub-class of it
            if (rb_obj_is_kind_of(rb_val, RB_CSTRUCT_CLASS) == Qtrue) {
              
                if ( rb_objc_convert_to_objc(rb_val, where, 0, type) == NO) {     
                    // if something went wrong in the conversion just return Qnil
                    rb_val = Qnil;
                    ret = NO;
                }
     
            } else {
                ret = NO;
            }
          }
          
            break;


        default:
            ret =NO;
            break; 
        }

        // skip the component we have just processed
        type = objc_skip_typespec(type);

    } while (inStruct && *type != _C_STRUCT_E);
  
    if (ret == NO) {
        /* raise exception - Don't know how to handle this type of argument */
        msg = [NSString stringWithFormat: @"Don't know how to convert Ruby type 0x%02x in ObjC type '%c'", TYPE(rb_thing), *type];
        NSDebugLog(msg);
        rb_raise(rb_eTypeError, [msg cString]);
    }

    return ret;
  
}


BOOL
rb_objc_convert_to_rb(void *data, int offset, const char *type, VALUE *rb_val_ptr, BOOL autoconvert)
{
    BOOL ret = YES;
    VALUE rb_class;
    double dbl_value;
    NSSelector *selObj;
    BOOL inStruct = NO;
    VALUE end = Qnil;


    if (*type == _C_STRUCT_B) {

        NSDebugLog(@"Starting conversion of ObjC structure %s to Ruby value", type);

        inStruct = YES;
        while (*type != _C_STRUCT_E && *type++ != '=');
        if (*type == _C_STRUCT_E) {
            // this is an empty structure !! Illegal... and we don't know
            // what to return
            *rb_val_ptr = Qundef;
            return NO;
        }
    }


  do {

      VALUE    rb_val;
      NSUInteger align;
      NSUInteger tsize;
      void	*where;

      type = objc_skip_type_qualifiers (type);
        
      NSDebugLog(@"Converting ObjC value (0x%lx) of type '%c' to Ruby value",
                 *(id*)data, *type);

      NSGetSizeAndAlignment(type, &tsize, &align);
      
      offset = ROUND(offset, align);
      where = data + offset;
        
      offset += tsize;

      switch (*type)
          {
          case _C_ID: {
              id val = *(id*)where;

              // Check if the ObjC object is already wrapped into a Ruby object
              // If so do not create a new object. Return the existing one
              if ( (rb_val = (VALUE) NSMapGet(knownObjects,(void *)val)) )  {
                      NSDebugLog(@"ObJC object already wrapped in an existing Ruby value (0x%lx)",rb_val);

              } else if (val == nil) {
                  
                  rb_val = Qnil;
                  
              } else if ( [val class] == [RIGSWrapObject class] ) {
                  
                  // This a native ruby object wrapped into an Objective C 
                  // nutshell. Returns what's in the nutshell
                  rb_val = [val getRubyObject];

              } else if ( autoconvert && [val isKindOfClass:[NSString class]] ) {
                  rb_val = [[val to_s] getRubyObject];
              } else if ( autoconvert && [val isKindOfClass:[NSNumber class]] ) {
                  rb_val = [[val to_n] getRubyObject];
              } else if ( autoconvert && [val isKindOfClass:[NSArray class]] ) {
                  rb_val = [[val to_a] getRubyObject];
              } else if ( autoconvert && [val isKindOfClass:[NSDictionary class]] ) {
                  rb_val = [[val to_h] getRubyObject];
              } else {
                  
                /* Retain the value otherwise GNUstep releases it and Ruby crashes
                                It's Ruby garbage collector job to indirectly release the ObjC 
                                object by calling rb_objc_release()
                            */
                  if ([val respondsToSelector: @selector(retain)]) {
                      [val retain];
                  }

                  Class retClass = [val classForCoder] ?: [val class];
                  
                  NSDebugLog(@"Class of arg transmitted to Ruby = %@",NSStringFromClass(retClass));

                  rb_class = (VALUE) NSMapGet(knownClasses, (void *)retClass);
                  
                  // if the class of the returned object is unknown to Ruby
                  // then register the new class with Ruby first
                  if (rb_class == Qfalse) {
                      rb_class = rb_objc_register_class_from_objc(retClass);
                  }
                  rb_val = Data_Wrap_Struct(rb_class,0,rb_objc_release,val);
              }
          }
          break;

        case _C_CHARPTR: 
          {
            // Convert char * to ruby String
            char *val = *(char **)where;
            if (val)
              rb_val = rb_str_new2(val);
            else 
              rb_val = Qnil;
          }
          break;

        case _C_PTR:
          {
            // A void * pointer is simply returned as its integer value
            rb_val = LL2NUM((long long) where);
          }
          break;

        case _C_CHR:
            // Assume that if YES or NO then it's a BOOLean
            if ( *(char *)where == YES) 
                rb_val = Qtrue;
            else if ( *(char *)where == NO)
                rb_val = Qfalse;
            else
                rb_val = CHR2FIX(*(char *)where);
            break;

        case _C_UCHR:
            rb_val = CHR2FIX(*(unsigned char *)where);
            break;

        case _C_SHT:
            rb_val = INT2FIX((int) (*(short *) where));
            break;

        case _C_USHT:
            rb_val = INT2FIX((int) (*(unsigned short *) where));
            break;

        case _C_INT:
            rb_val = INT2FIX(*(int *)where);
            break;

        case _C_UINT:
            rb_val = UINT2NUM(*(unsigned int*)where);
            break;

        case _C_LNG:
            rb_val = LONG2NUM(*(long*)where);
            break;

        case _C_ULNG:
            rb_val = ULONG2NUM(*(unsigned long*)where);
            break;

        case _C_LNG_LNG:
            rb_val = LL2NUM(*(long long*)where);
            break;

        case _C_ULNG_LNG:
            rb_val = ULL2NUM(*(unsigned long long*)where);
            break;
            
        case _C_FLT:
          {
            // FIXME
            // This one doesn't crash but returns a bad floating point
            // value to Ruby. val doesn not contain the expected float
            // value. why???
            NSDebugLog(@"ObjC val for float = %f", *(float*)where);
            
            dbl_value = (double) (*(float*)where);
            NSDebugLog(@"Double ObjC value returned = %lf",dbl_value);
            rb_val = rb_float_new(dbl_value);
          }
          break;

        case _C_DBL:
            NSDebugLog(@"Double float Value returned = %lf",*(double*)where);
             rb_val = rb_float_new(*(double*)where);
            break;


        case _C_CLASS:
          {
            Class val = *(Class*)where;
            
            NSDebugLog(@"ObjC Class = 0x%lx", val);
            rb_class = (VALUE) NSMapGet(knownClasses, (void *)val);

            // if the Class is unknown to Ruby then register it 
            // in Ruby in return the corresponding Ruby class VALUE
            if (rb_class == Qfalse) {
                rb_class = rb_objc_register_class_from_objc(val);
            }
            rb_val = rb_class;
          }
          break;
          
        case _C_SEL: 
          {
            SEL val = *(SEL*)where;
            
            NSDebugLog(@"ObjC Selector = 0x%lx", val);
            // ObjC selectors can either be returned as an instance of class NSSelector
              
            // Before instantiating NSSelector make sure it is known to
            // Ruby
            rb_class = (VALUE) NSMapGet(knownClasses, (void *)[NSSelector class]);

            if (rb_class == Qfalse) {
                rb_class = rb_objc_register_class_from_objc([NSSelector class]);
            }
            selObj = [[NSSelector selectorWithSEL: (SEL)val] retain];
            rb_val = Data_Wrap_Struct(rb_class,0,rb_objc_release,selObj);
          }
          break;

          case _C_STRUCT_B: 
            {

              // We are attacking a new embedded structure in a structure
            
          
            if ( rb_objc_convert_to_rb(where, 0, type, &rb_val, autoconvert) == NO) {     
                // if something went wrong in the conversion just return Qnil
                rb_val = Qnil;
                ret = NO;
            } 
            }
            
            break; 

        default:
            NSLog(@"Don't know how to convert ObjC type '%c' to Ruby VALUE",*type);
            rb_val = Qnil;
            ret = NO;
            
            break;
        }

      if (inStruct) {

          // We are in a C structure 

          if (end == Qnil) {
              // first time in there so allocate a new Ruby array
              end = RB_CSTRUCT_NEW();
              RB_CSTRUCT_PUSH(end, rb_val);
              *rb_val_ptr = end;
              
          } else {
              // Next component in the same structure. Append it to 
              // the end of the running Ruby array
              RB_CSTRUCT_PUSH(end, rb_val);
          }


      } else {
          // We are not in a C structure so simply return the
          // Ruby value
          *rb_val_ptr = rb_val;
      }
     
      // skip the type of the component we have just processed
      type = (char*)objc_skip_typespec(type);

 
 
  } while (inStruct && *type != _C_STRUCT_E);

  NSDebugLog(@"End of ObjC to Ruby conversion");
    
  return ret;

}


VALUE
rb_objc_send(char *method, int rigs_argc, VALUE *rigs_argv, VALUE rb_self)
{
    SEL sel;
    @autoreleasepool {

    NSDebugLog(@"<<<< Invoking method %s with %d argument(s) on Ruby VALUE 0x%lx (Objc id 0x%lx)",method, rigs_argc, rb_self);

    sel = SelectorFromRubyName(method, rigs_argc);
    return rb_objc_send_with_selector(sel, rigs_argc, rigs_argv, rb_self);
    }
}


VALUE
rb_objc_send_with_selector(SEL sel, int rigs_argc, VALUE *rigs_argv, VALUE rb_self)
{
    @autoreleasepool {
    id rcv;
    NSInvocation *invocation;
    NSMethodSignature	*signature;
    const char *type;
    VALUE rb_retval = Qnil;
    int i;
    int nbArgs;
    void *data;
    BOOL okydoky;
        
        
    /* determine the receiver type - Class or instance ? */
    switch (TYPE(rb_self)) {

    case T_DATA:
        NSDebugLog(@"Self Ruby value is 0x%lx (ObjC is at 0x%lx)",rb_self,DATA_PTR(rb_self));
        
        Data_Get_Struct(rb_self,id,rcv);
        
        NSDebugLog(@"Self is an object of Class %@ (description is '%@')",NSStringFromClass([rcv class]),rcv);
      break;

    case T_CLASS:
        rcv = (id) NUM2LL(rb_iv_get(rb_self, "@objc_class"));
        NSDebugLog(@"Self is Class: %@", NSStringFromClass(rcv));
      break;

    default:
      /* raise exception */
      NSDebugLog(@"Don't know how to handle self Ruby object of type 0x%02x",TYPE(rb_self));
      rb_raise(rb_eTypeError, "not valid self value");
      return Qnil;
      break;
      
    }
  
      
    // Find the method signature 
    // FIXME: do not know what happens here if several method have the same
    // selector and different return types (see gg_id.m / gstep_send_fn ??)
    signature = [rcv methodSignatureForSelector: sel];
    if (signature == nil) {
        NSLog(@"Did not find signature for selector '%@' ..", 
              NSStringFromSelector(sel));
        return Qnil;
    }
  

    // Check that we have the right number of arguments
    nbArgs = [signature numberOfArguments];
    if ( nbArgs != rigs_argc+2) {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for %d)",rigs_argc, nbArgs-2);
        return Qnil;
    }
    
    NSDebugLog(@"Number of arguments = %d", nbArgs-2);

    // Create an Objective C invocation based on the  signature
    // and convert arguments from Ruby VALUE to ObjC types
    invocation = [NSInvocation invocationWithMethodSignature: signature];
    [invocation setTarget: rcv];
    [invocation setSelector: sel];
	
    for(i=2; i < nbArgs; i++) {

        type = [signature getArgumentTypeAtIndex: i];
        NSUInteger tsize;
        NSGetSizeAndAlignment(type, &tsize, NULL);
        data = alloca(tsize);
                        
        okydoky = rb_objc_convert_to_objc(rigs_argv[i-2], data, 0, type);
        [invocation setArgument: data atIndex: i];
    }
 
    // Really invoke the Obj C method now
    [invocation invoke];

    // Examine the return value now and pass it by to Ruby
    // after conversion
    if([signature methodReturnLength]) {
      
        type = [signature methodReturnType];
            
        NSDebugLog(@"Return Length = %d", [[invocation methodSignature] methodReturnLength]);
        NSDebugLog(@"Return Type = %s", type);
        
        data = alloca([signature methodReturnLength]);
        [invocation getReturnValue: data];

        // Won't work if return length > sizeof(int)  but we do not care
        // (e.g. double on 32 bits architecture)
        NSDebugLog(@"ObjC return value = 0x%lx",data);

        okydoky = rb_objc_convert_to_rb(data, 0, type, &rb_retval, NO);

    } else {
        // This is a method with no return value (void). Must return something
        // in any case in ruby. So return Qnil.
        NSDebugLog(@"No ObjC return value (void) - returning Qnil",data);
        rb_retval = Qnil;
    }
        
        
    NSDebugLog(@">>>>> VALUE returned to Ruby = 0x%lx (class %s)",
               rb_retval, rb_class2name(CLASS_OF(rb_retval)));
        
    return rb_retval;
    }
}

VALUE 
rb_objc_handler(int rigs_argc, VALUE *rigs_argv, VALUE rb_self)
{    
	return rb_objc_send(rb_id2name(rb_frame_this_func()), rigs_argc, rigs_argv, rb_self);
}

VALUE
rb_objc_invoke(int rigs_argc, VALUE *rigs_argv, VALUE rb_self)
{
	char *method = rb_id2name(SYM2ID(rigs_argv[0]));
 
	return rb_objc_send(method, rigs_argc-1, rigs_argv+1, rb_self);
}

NSArray* 
class_method_selectors_for_class(Class class, BOOL use_super)
{    
  Class meta_class =  class_get_meta_class(class);
  return(method_selectors_for_class(meta_class, use_super));
}

NSArray* 
instance_method_selectors_for_class(Class class, BOOL use_super)
{
  return(method_selectors_for_class(class, use_super));
}

NSArray* 
method_selectors_for_class(Class class, BOOL use_super)
{
  NSMutableSet *methodSet = [NSMutableSet new];
  int i;
  int unsigned numMethods;

  while(class) {

    Method *methods = class_copyMethodList(class, &numMethods);
    for (i = 0; i < numMethods; i++) {
        SEL sel = method_getName(methods[i]);
        [methodSet addObject: NSStringFromSelector(sel)];
    }
    free(methods);
    
    if(use_super)
      class = class_getSuperclass(class);
    else
      class = NULL;
  }

  return [methodSet allObjects];
}

int rb_objc_register_instance_methods(Class objc_class, VALUE rb_class)
{
    NSArray *allMthSels;
    NSEnumerator *mthEnum;
    NSString *mthSel;
    NSString *mthRubyName;
    int imth_cnt = 0;

    //Store the ObjcC Class id in the @@objc_class Ruby Class Variable
    rb_iv_set(rb_class, "@objc_class", LL2NUM((long long)objc_class));
    
    /* Define all Ruby Instance methods for this Class */
    allMthSels = method_selectors_for_class(objc_class, NO);
    mthEnum = [allMthSels objectEnumerator];
    
    while ( (mthSel = [mthEnum nextObject]) ) {
       
        mthRubyName = RubyNameFromSelectorString(mthSel);
        //NSDebugLog(@"Registering Objc method %@ under Ruby name %@)", mthSel,mthRubyName);

        rb_define_method(rb_class, [mthRubyName cString], rb_objc_handler, -1);
        imth_cnt++;
    }

    return imth_cnt;
    
}

int rb_objc_register_class_methods(Class objc_class, VALUE rb_class)
{
    NSArray *allMthSels;
    NSEnumerator *mthEnum;
    NSString *mthSel;
    NSString *mthRubyName;
    Class objc_meta_class = class_get_meta_class(objc_class);
    
    int cmth_cnt = 0;

    
    /* Define all Ruby Class (singleton) methods for this Class */
    allMthSels = method_selectors_for_class(objc_meta_class, NO);
    mthEnum = [allMthSels objectEnumerator];
    
    while ( (mthSel = [mthEnum nextObject]) ) {
       
        mthRubyName = RubyNameFromSelectorString(mthSel);
        //NSDebugLog(@"Registering Objc class method %@ under Ruby name %@)", mthSel,mthRubyName);

        rb_define_singleton_method(rb_class, [mthRubyName cString], rb_objc_handler, -1);
        cmth_cnt++;
     }

    // Redefine the new method to point to our special rb_objc_new function
    rb_undef_method(CLASS_OF(rb_class),"new");
    rb_define_singleton_method(rb_class, "new", rb_objc_new, -1);

    return cmth_cnt;
}


VALUE
rb_objc_register_class_from_objc (Class objc_class)
{

    @autoreleasepool {
    const char *cname = [NSStringFromClass(objc_class) cString];

    Class objc_super_class = class_getSuperclass(objc_class);
    VALUE rb_class;
    VALUE rb_super_class = Qnil;
    //    NSNumber *rb_class_value;
    int imth_cnt;
    int cmth_cnt;

    NSDebugLog(@"Request to register ObjC Class %s (ObjC id = 0x%lx)",cname,objc_class);

    // If this class has already been registered then return existing
    // Ruby class VALUE
    rb_class = (VALUE) NSMapGet(knownClasses, (void *)objc_class);

    if (rb_class) {
       NSDebugLog(@"Class %s already registered (VALUE 0x%lx)", cname, rb_class);
       return rb_class;
    }

    // If it is not the mother of all classes then create the
    // Ruby super class first
    if ((objc_class == [NSObject class]) || (objc_super_class == nil)) 
        rb_super_class = rb_cObject;
    else
        rb_super_class = rb_objc_register_class_from_objc(objc_super_class);

    /* FIXME? A class name in Ruby must be constant and therefore start with
          A-Z character. If this is not the case the following method call will work
          ok but the Class name will not be explicitely accessible from Ruby
          (Rigs.import deals with Class with non Constant name to avoid NameError
          exception */
    rb_class = rb_define_class_under(rb_mRigs, cname, rb_super_class);

    cmth_cnt = rb_objc_register_class_methods(objc_class, rb_class);
    imth_cnt = rb_objc_register_instance_methods(objc_class, rb_class);

    NSDebugLog(@"%d instance and %d class methods defined for class %s",imth_cnt,cmth_cnt,cname);

    // Remember that this class is now defined in Ruby
    NSMapInsertKnownAbsent(knownClasses, (void*)objc_class, (void*)rb_class);
    
    NSDebugLog(@"VALUE for new Ruby Class %s = 0x%lx",cname,rb_class);

    // Execute Post registration code if it exists
    if ( [objc_class respondsToSelector: @selector(finishRegistrationOfRubyClass:)] ) {
      [objc_class finishRegistrationOfRubyClass: rb_class];
    } else {
      NSDebugLog(@"Class %@ doesn't respond to finish registration method",NSStringFromClass(objc_class));
    } 

    // also make sure to load the corresponding ruby file and execute
    // any additional Ruby code for this class
    // it is like: Rigs.import(cname)
    // FIXME: It goes into recursive call with the Ruby NSxxx.rb code and leads
    // to top level constant defined twice (warning). Need to fix that...
    NSDebugLog(@"Calling ObjRuby.import(%s) from Objc", cname);
    
    rb_funcall(rb_mRigs, rb_intern("import"), 1,rb_str_new2(cname));
    
    // Define a top level Ruby constant  with the same name as the class name
    // No don't do that! Force user to use Rigs#import on the Ruby side to
    // load any additional Ruby code if there is some
    //rb_define_global_const(cname, rb_class);

    return rb_class;
    }
}

VALUE
rb_objc_register_class_from_ruby(VALUE rb_self, VALUE rb_name)
{
    @autoreleasepool {
    char *cname = rb_string_value_cstr(&rb_name);
    VALUE rb_class = Qnil;

    Class objc_class = NSClassFromString([NSString stringWithCString: cname]);
    
    if(objc_class)
        rb_class = rb_objc_register_class_from_objc(objc_class);

    return rb_class;
    }
}

VALUE
rb_objc_get_ruby_value_from_string(char * classname)
{
    char *evalstg;
    VALUE rbvalue;
    
    // Determine the VALUE of a Ruby Class based on its name
    // Not sure this is the official way of doing it... (FIXME?)
    evalstg = malloc(strlen(classname)+5);
    strcpy(evalstg,classname);
    strcat(evalstg,".id");
    // FIXME??: test if equivalent to ID2SYM(rb_eval_string(evalstg))
    rbvalue = rb_eval_string(evalstg) & ~FIXNUM_FLAG;
    free(evalstg);

    return rbvalue;
}


void
rb_objc_raise_exception(NSException *exception)
{
    VALUE rb_rterror_class, rb_exception;
    
    NSDebugLog(@"Uncaught Objective C Exception raised !");
    NSDebugLog(@"Name:%@  / Reason:%@  /  UserInfo: ?",
               [exception name],[exception reason]);

    // Declare a new Ruby Exception Class on the fly under the RuntimeError
    // exception class
    // Rk: the 1st line below  is the only way I have found to get access to
    // the VALUE of the RuntimeError class. Pretty ugly.... but it works.
    //    rb_rterror_class = rb_eval_string("RuntimeError.id") & ~FIXNUM_FLAG;
    rb_rterror_class = rb_objc_get_ruby_value_from_string("RuntimeError");
    rb_exception = rb_define_class([[exception name] cString], rb_rterror_class);
    rb_raise(rb_exception, [[exception reason] cString]);
    
}



/* Rebuild ObjC argc and argv from the Ruby context */
void
_rb_objc_rebuild_argc_argv(VALUE rigs_argc, VALUE rigs_argv)
{
    int i;
    VALUE entry;
    VALUE tmp;

    // +1 in arcg for the script name that is not in ARGV in Ruby
    ourargc = FIX2INT(rigs_argc)+1;
    
    ourargv = malloc(sizeof(char *) * ourargc);
    tmp = rb_gv_get("$0");
    ourargv[0] = rb_string_value_cstr(&tmp);

    NSDebugLog(@"Argc=%d\n",ourargc);
    NSDebugLog(@"Argv[0]=%s\n",ourargv[0]);
     
    for (i=1;i<ourargc; i++) {
        entry = rb_ary_entry(rigs_argv,(long)(i-1));
        ourargv[i] = rb_string_value_cstr(&entry);     
        NSDebugLog(@"Argv[%d]=%s\n",i,ourargv[i]);
    }
    
}


/*  Now try and ask process info. If an exception is raised then it means
    we are on a platform where NSProcessInfo +initializeWithArguments
    was not automaitcally called at run time. In this case we must call it
    ourself.
    If it doesn't raise an exception then we need to patch the main Bundle
    to reflect the real location of the Tool/Application otherwise it simply
    says /usr/loca/bin (where Ruby) is and none of the Tool/Application
    resources are visible

    The goal of this function is twofold:

    1) Update the NSProcessInfo information with real argc, argv and env
        (argv needs to be modified so that argv[0] reflects the ruby script
        path as a process name instead of simply "ruby"

    2) Modify the Main NSBundle to reflect the ruby script executable path of
        because otherwise the executable path always says /usr/local/bin/ruby
        and NSBundle never finds the application Resources (plist files, etc...)
*/
void _rb_objc_initialize_process_context(VALUE rigs_argc, VALUE rigs_argv)
{
    NSProcessInfo *pi = nil;
    NSString *topProgram;
    @autoreleasepool {
        
    // rebuild our own argc and argv from what Ruby gives us
    _rb_objc_rebuild_argc_argv(rigs_argc, rigs_argv);

     pi = [NSProcessInfo processInfo];

    // Process Info still null ? It shouldn't...
    if (pi == nil) {
        [NSException raise:NSInternalInconsistencyException
                     format:@"Process Info still un-initialized !!"];
    }

    NSDebugLog(@"Arguments in NSProcessInfo before rebuild: %@",[[NSProcessInfo processInfo] arguments]);
    
    // If the top level program being executed is not the ruby interpreter then
    // we are probably executing Ruby scripts from within an embedded Scripts
    // In this case do not rework the process context.
    // FIXME: Find a better way to determine that ruby was not the top level 
    // program but that a ObjC program - embedding a Ruby script - is
    topProgram = [[[NSProcessInfo processInfo] arguments] objectAtIndex: 0];
    if ( ![topProgram hasSuffix: @"ruby"] ) {
      // We are not executing from a top level Ruby interpreter
      NSDebugLog(@"Top level program (%@) not a ruby interpreter. Process context untouched", topProgram);
      return;
      
    }
    
    NSDebugLog(@"Arguments in NSProcessInfo after rebuild: %@",[[NSProcessInfo processInfo] arguments]);
    
    NSDebugLog(@"New Main Bundle path: %@", [[NSBundle mainBundle] bundlePath]);

    }
    
}



/* Called when require 'obj_ext' is executed in Ruby */
void
Init_obj_ext()
{
    VALUE rigs_argv, rigs_argc;

    // Catch all GNUstep raised exceptions and direct them to Ruby
    NSSetUncaughtExceptionHandler(rb_objc_raise_exception);

    // Initialize hash tables of known Objects and Classes
    knownClasses = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
                                    NSNonOwnedPointerMapValueCallBacks,
                                    0);
    knownObjects = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
                                    NSNonOwnedPointerMapValueCallBacks,
                                    0);
    
    // Create 2 ruby class methods under the ObjC Ruby module
    // - ObjRuby.class("className") : registers ObjC class with Ruby
    // - ObjRuby.register(class): register Ruby class with Objective C

    rb_mRigs = rb_define_module("ObjRuby");
    rb_define_singleton_method(rb_mRigs, "class", rb_objc_register_class_from_ruby, 1);
    rb_define_singleton_method(rb_mRigs, "register", _RIGS_register_ruby_class_from_ruby, 1);
 
    // Define the NSNotFound enum constant that is used all over the place
    // as a return value by Objective C methods
    rb_define_global_const("NSNotFound", LL2NUM((long long)NSNotFound));
    
    // Initialize Process Info and Main Bundle
    rigs_argv = rb_gv_get("$*");
    rigs_argc = INT2FIX(RARRAY_LEN(RARRAY(rigs_argv)));

    _rb_objc_initialize_process_context(rigs_argc, rigs_argv);
}

