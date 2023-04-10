/* RIGSNSApplication.m - Some additional code to properly wrap the
   NSApplication class in Ruby

   $Id$

   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Laurent Julliard <laurent@julliard-online.org>
   Date: August 2001
   
   This file is part of the GNUstep RubyInterface Library.

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

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>


#include "RIGS.h"
#include "RIGSCore.h"
#import "RIGSNSApplication.h"


// Ruvy view of the NSApp global GNUstep variable
static VALUE rb_NSApp = Qnil;

VALUE _RIGS_get_NSApp(ID rb_id, VALUE *data, global_entry_ptr entry) 
{
  DATA_PTR(rb_NSApp) = NSApp;
  return rb_NSApp;
}

void _RIGS_set_NSApp(VALUE value, ID rb_id, VALUE *data, global_entry_ptr entry) 
{
  
  Data_Get_Struct(value, NSApplication, NSApp);
  DATA_PTR(rb_NSApp) = NSApp;
  NSDebugLog(@"Setting NSApp to 0x%lx", NSApp);
  
}

void
_RIGS_rebuild_argc_argv(VALUE rb_argc, VALUE rb_argv)
{
    int i;

    // +1 in arcg for the script name that is not in ARGV in Ruby
    ourargc = FIX2INT(rb_argc)+1;
    
    ourargv = malloc(sizeof(char *) * ourargc);
    VALUE tmp = rb_gv_get("$0");
    ourargv[0] = rb_string_value_cstr(&tmp);
    NSDebugLog(@"Argc=%d\n",ourargc);
    NSDebugLog(@"Argv[0]=%s\n",ourargv[0]);
     
    for (i=1;i<ourargc; i++) {
        VALUE e = rb_ary_entry(rb_argv,(long)(i-1));
        ourargv[i] = rb_string_value_cstr(&e);     
        NSDebugLog(@"Argv[%d]=%s\n",i,ourargv[i]);
    }
    
}



/* This function can be passed 0 argument or 2.
   - If no argument is given then just call NSApplicationMain()
   - If 2 arguments  are passed they are new argc and argv that
      are going to override the one we built automatically when 
      librigs was loaded 

    argc in the form of a FIXNUM, and argv in the form of a Ruby
    array (unlike C argv[0] doens't contain the script name which is
    always in $0))
*/
VALUE _NSApplicationMainFromRuby(int arg_count, VALUE *arg_values, VALUE self) 
{

    @autoreleasepool {
  
    NSDebugLog(@"Arguments in NSProcessInfo before rebuild: %@",[[NSProcessInfo processInfo] arguments]);


    if (arg_count == 0) {

        // Nothing to be done. Use the defaults as set when librigs
        // was loaded (See RIGSCore.m)

    } else if (arg_count == 2) {

        // So explicit arguments where passed from Ruby. This is really
        // unusual but in this case re-configure again the process context
        VALUE rigs_argc = arg_values[0];
        VALUE rigs_argv = arg_values[1];
        if ( (TYPE(rigs_argc) != T_FIXNUM) || (TYPE(rigs_argv) != T_ARRAY) ) {
            rb_raise(rb_eTypeError, "invalid type of arguments (must be an Integer and an Array)");
        }

        // Rebuild argv and argc from Ruby ARGV array
        _rb_objc_initialize_process_context(rigs_argc, rigs_argv);
      

    } else {
        rb_raise(rb_eArgError, "wrong # of arguments (%d for 0 or 2)", arg_count);
    }
        

  
    return INT2FIX(NSApplicationMain(ourargc,(const char **)ourargv));
    }
}


@implementation NSApplication ( RIGSNSApplication )

+ (BOOL) finishRegistrationOfRubyClass: (VALUE) ruby_class
{

  // We need to define the global variable $NSApp in Ruby
  // and make it a variable hooked to the Objective C NSApp
  
  // if global variable is already defined then give up (this
  // method should only be called once !
  if ( rb_NSApp != Qnil ) {
    NSLog(@"finishRegistrationOfRubyClass: called more than once for NSApplication! Doing nothing...");
    return NO;
  }

  // Create a Ruby DATA structure embedding the NSApp global variable
  // and make it available as $NSApp global variable in Ruby.
  rb_NSApp = Data_Wrap_Struct(ruby_class, 0, 0, nil);
  rb_define_hooked_variable("$NSApp",&rb_NSApp,
                            _RIGS_get_NSApp,_RIGS_set_NSApp);

  // Also define a global Ruby method equivalent to NSApplicationMain
  rb_define_global_function("NSApplicationMain", _NSApplicationMainFromRuby,-1);

  return YES;

}

@end
      
