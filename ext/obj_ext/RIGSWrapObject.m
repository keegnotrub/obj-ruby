/* RIGSWrapObject.m - Wrapping Ruby Objects into GNUstep-like objects
   Copyright (C) 2001 Free Software Foundation, Inc.

   $Id$
   
   Written by:  Laurent Julliard
   Date: July 2001
   
   This file is part of the GNUstep Ruby Interface Library.

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

/*
  The RIGSWrapObject class provides a fallback mechanism to
  handle all Ruby native Objects passed to ObjC for which there is
  no specific conversion mechanism. Any method called from ObjC
  on this kind of object will be redirected to the forwardInvocation
  method
*/

#include <objc/runtime.h>

#include <Foundation/NSDictionary.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSInvocation.h>
#include <Foundation/NSMethodSignature.h>
#include <Foundation/NSAutoreleasePool.h>

#include "RIGS.h"
#include "RIGSCore.h"
#include "RIGSWrapObject.h"
#include "RIGSSelectorMapping.h"

static NSMutableDictionary *_rodict = NULL;

@implementation RIGSWrapObject : NSObject


+ (void) initialize
{

  if (_rodict == NULL)
    {
      _rodict = [[NSMutableDictionary alloc] init];    
    }
}

+ (id) objectWithRubyObject: (VALUE)rubyObject
{
  id obj;
  NSNumber *robj;

  robj = [NSNumber numberWithUnsignedLong:rubyObject];

  if ( !(obj = [_rodict objectForKey:robj]) )
    {
      obj = [[self alloc] initWithRubyObject: rubyObject];
    }
 
  return obj;
  
}

- (void) dealloc
{
  NSDebugLog(@"Deallocating RIGSWrapObject 0x%lx", self);
  [_rodict removeObjectForKey: [NSNumber numberWithUnsignedLong:_ro]];
  [super dealloc];
}

- (VALUE) getRubyObject
{
  return _ro;
}

/* Return the description of the native ruby object */
- (NSString *) description
{
  VALUE rbval = rb_funcall(_ro,rb_intern("to_s"), 0);
  return( [NSString stringWithCString:
                      rb_string_value_cstr(&rbval)] );
}


- (id) initWithRubyObject: (VALUE)rubyObject
{
  /* FIXME:  how do we known when the wrapped ruby object has
     been disposed of on the Ruby side and we must delete the 
     corresponding RIGSWrapObject ?? */
  self = [self init];
  _ro = rubyObject;
  [_rodict setObject: self
              forKey: [NSNumber numberWithUnsignedLong:rubyObject]];
  return self;
}


/*
  Catch all unknown messages sent to a Wrapped Ruby Object, derive
  the corresponding Ruby ID and call the ruby method.
  Remark: since we now have the ability to create an ObjC proxy class for
  each Ruby object that enters the ObjC realm, this method should never be
  called. 
*/
- (void) forwardInvocation: (NSInvocation *)anInvocation
{
    @autoreleasepool {
    int nbArgs;
    int mthReturnLength;
    unsigned int i;
    VALUE *rbargs, rbval;
    id objcArg;
    NSString *rb_mth_name;
    BOOL okydoky;
    void *data;
    NSMethodSignature	*signature;
    const char *type;
    
    
    /* 
       An objectice C message is sent to a wrapped ruby object. And if we get
       here then it means that there is no corresponding proxy method registered
       with ObjC. So build the method name from the selector and call Ruby
       method. We leave it to Ruby to handle the case where the method doesn't exist
    */

    signature = [anInvocation methodSignature];
    nbArgs = [signature numberOfArguments];

    NSDebugLog(@"Wrapped Ruby Object Invocation");
    NSDebugLog(@"   -target: ObjC id (self = 0x%lx, target = 0x%lx), Ruby value (0x%lx)",
               self,[anInvocation target],_ro);
    NSDebugLog(@"   -nb of arguments",[signature numberOfArguments]);
    
    // Method name
    rb_mth_name = RubyNameFromSelector([anInvocation selector]);
    NSDebugLog(@"   -method: %@", rb_mth_name);
    
    // Collect arguments, transform them to Ruby values
    rbargs = malloc((nbArgs-2) * sizeof(VALUE));
    
    for(i=2; i < nbArgs; i++) {

        [anInvocation getArgument:&objcArg atIndex:i ];

        type = [signature getArgumentTypeAtIndex: i];
        NSUInteger tsize;
        NSGetSizeAndAlignment(type, &tsize, NULL);
        data = alloca(tsize);
        [anInvocation getArgument:data atIndex:i ];

        NSDebugLog(@"   -arg%d: ObjC id 0x%lx, type %c", *(id *)data,*type);
        okydoky = rb_objc_convert_to_rb(data, 0, type, &rbargs[i]);
    }

    /*
      Now call the corresponding Ruby method with the same selector
      We leave it to Ruby to raise exception if the method is missing
      */
    rbval = rb_funcall2(_ro, rb_intern([rb_mth_name cString]), nbArgs, rbargs);
    
    free(rbargs);
    
    mthReturnLength = [signature methodReturnLength];
    
    if(mthReturnLength) {
        
      type = [signature methodReturnType];
      data = alloca(mthReturnLength);
      okydoky = rb_objc_convert_to_objc(rbval, data, 0, type);

      [anInvocation setReturnValue:data];
    }
    
    }
    
}

/* NSObject methods that must be redefined to behave properly */

// Check if a Ruby Wrapped Object respond to a given Selector
- (BOOL) respondsToSelector: (SEL)aSelector
{
  NSString* rbSELstg;
  BOOL ycause = NO;

  rbSELstg = RubyNameFromSelector(aSelector);

  if (rb_respond_to(_ro, rb_intern([rbSELstg cString])) == Qtrue)
      {
          ycause = YES;
      }
      

  NSDebugLog(@"Does Ruby Wrapped object 0x%lx responds to '%@' : %d", self, rbSELstg, ycause); 
  return ycause;
  
}

- (id) performSelector: (SEL)aSelector
{
  NSString* rbSELstg;
  VALUE rbval;
  const char idType[] = {_C_ID,'\0'};
  id objcRet;

  rbSELstg = RubyNameFromSelector(aSelector);

  NSDebugLog(@"Ruby Wrapped Object received performSelector:  '%@'",rbSELstg);

  rbval = rb_funcall(_ro, rb_intern([rbSELstg cString]), 0);
  rb_objc_convert_to_objc(rbval, (void*)&objcRet, 0, idType);
  return objcRet;
  
}

- (id) performSelector: (SEL)aSelector withObject: anObject
{
  NSString* rbSELstg;
  VALUE rbval, rbarg;
  const char idType[] = {_C_ID,'\0'};
  id objcRet;
  BOOL okydoky;


  rbSELstg = RubyNameFromSelector(aSelector);

  NSDebugLog(@"Ruby Wrapped Object received performSelector:  '%@' withObject: %@",rbSELstg, anObject);

  okydoky = rb_objc_convert_to_rb((void *)&anObject,0,idType,&rbarg);

  rbval = rb_funcall(_ro, rb_intern([rbSELstg cString]), 1, rbarg);

  okydoky = rb_objc_convert_to_objc(rbval,(void*)&objcRet, 0, idType );

  return objcRet;

}

- (id) performSelector: (SEL)aSelector withObject: object1 withObject: object2
{
  NSString* rbSELstg;
  VALUE rbval, rbarg1, rbarg2;
  const char idType[] = {_C_ID,'\0'};
  id objcRet;
  BOOL okydoky;

  rbSELstg = RubyNameFromSelector(aSelector);

  NSDebugLog(@"Ruby Wrapped Object received performSelector:  '%@' withObject: %@ withObject: %@",rbSELstg, object1, object2);

  okydoky = rb_objc_convert_to_rb((void *)&object1,0,idType,&rbarg1);
  okydoky = rb_objc_convert_to_rb((void *)&object2,0,idType,&rbarg2);

  rbval = rb_funcall(_ro, rb_intern([rbSELstg cString]), 2, rbarg1, rbarg2); 
 
  okydoky = rb_objc_convert_to_objc(rbval,(void*)&objcRet, 0, idType );
  return objcRet;

}


@end
