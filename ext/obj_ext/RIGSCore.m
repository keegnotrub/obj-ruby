/* RIGSCore.m - Ruby Interface to Objective-C

   Written by: Ryan Krug <ryank@kit.com>
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

   History:
   - Original code from Avi Bryant's cupertino test project <avi@beta4.com>
   - Code patiently improved and augmented by Laurent Julliard <laurent@julliard-online.org>
   - Then once again by Ryan Krug <ryank@kit.com>

*/

#import "RIGSCore.h"
#import "RIGSUtilities.h"
#import "RIGS.h"
#import "RIGSNSDictionary.h"
#import "RIGSNSArray.h"
#import "RIGSNSString.h"
#import "RIGSNSNumber.h"
#import "RIGSNSDate.h"
#import "RIGSBridgeSupportParser.h"

// Hash table  that maps known ObjC class to Ruby class VALUE
static NSMapTable *knownClasses = 0;

// Hash table that maps known ObjC objects to Ruby object VALUE
static NSMapTable *knownObjects = 0;

// Hash table that maps known ObjC structs to Ruby struct VALUE
static NSMapTable *knownStructs = 0;

// Hash table that maps known ObjC functions to objcTypes encoding
static NSMapTable *knownFunctions = 0;

// Hash table that maps known ObjC selectors to block objcTypes encoding
static NSMapTable *knownBlocks = 0;

// Hash table that maps known ObjC selectors to objcTypes encoding
static NSMapTable *knownProtocols = 0;

// Hash table that maps known objcTypes encoding to Ruby proxy method implementations
static NSMapTable *knownImplementations = 0;

// Hash table that maps known ObjC selectors to printf arg positions (index+1)
static NSMapTable *knownFormatStrings = 0;

// Hash table that contains loaded Framework bundleIdentifiers
static NSHashTable *knownFrameworks = 0;

// Rigs Ruby module
static VALUE rb_mRigs = Qnil;

// Rigs Ruby Ptr class
static VALUE rb_cRigsPtr = Qnil;

void
rb_objc_release(id objc_object) 
{
  NSDebugLog(@"Call to ObjC release on %p", objc_object);

  if (objc_object != nil) {
    @autoreleasepool {
      /* Use an autorelease pool here because both `repondsTo:` and
         `release` could autorelease objects. */

      NSMapRemove(knownObjects, (void*)objc_object);
      if ([objc_object respondsToSelector: @selector(release)]) {
        [objc_object release];
      }
    }
  }
 
}


const char *
rb_objc_sanitize_objc_types(const char *objcTypes)
{
  NSMethodSignature *signature;
  NSMutableString	*str;
  NSUInteger nbArgs;
  NSUInteger i;
  
  signature = [NSMethodSignature signatureWithObjCTypes:objcTypes];
  
  str = [NSMutableString stringWithCapacity: 128];
  [str appendFormat: @"%s", [signature methodReturnType]];
  nbArgs = [signature numberOfArguments];
  
  for (i=0;i<nbArgs;i++) {
    [str appendFormat: @"%s", [signature getArgumentTypeAtIndex:i]];
  }
  
  return [str UTF8String];  
}


/* 
   Normally new method has no arg in objective C. 
   If you want it to have arguments when using new from Ruby then
   override the new method from Ruby.
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

    NSUInteger cnt = NSCountMapTable(knownObjects);
    obj  = [[objc_class alloc] init];
    BOOL proxied = cnt != NSCountMapTable(knownObjects);

    new_rb_object = (VALUE)NSMapGet(knownObjects, (void*)obj);

    if (new_rb_object == Qfalse) {
      new_rb_object = Data_Wrap_Struct(rb_class, 0, rb_objc_release, obj);

      NSDebugLog(@"Creating new object of Class %@ (id = %p, VALUE = %p)",
                 NSStringFromClass([objc_class classForCoder]), obj, (void*)new_rb_object);
   
      NSMapInsertKnownAbsent(knownObjects, (void*)obj, (void*)new_rb_object);
    }
    else if (!proxied) {
      NSDebugLog(@"Found existing object of Class %@ (id = %p, VALUE = %p)",
                 NSStringFromClass([objc_class classForCoder]), obj, (void*)new_rb_object);
      
      [obj release];
    }

    return new_rb_object;
  }
}

void
rb_objc_ptr_retain(VALUE rcv)
{
  @autoreleasepool {
    struct rb_objc_ptr *dp;
    id obj;
    size_t offset = 0;

    dp = (struct rb_objc_ptr*)DATA_PTR(rcv);

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
}

ffi_type*
rb_objc_ffi_type_for_type(const char *type)
{
  ffi_type *inStruct = NULL;
  unsigned long inStructHash;
  int inStructIndex = 0;
  long inStructCount = 0;

  type = objc_skip_type_qualifiers (type);

  if (strcmp(type, "@?") == 0) {
    return &ffi_type_pointer;
  }

  if (*type == _C_STRUCT_B) {
    inStructHash = HASH_SEED;
    while (*type != _C_STRUCT_E && *type++ != '=') {
      if (*type == '=') continue;
      inStructHash = ((inStructHash << HASH_BITSHIFT) + inStructHash) + (*type);
    }
    inStructCount = rb_array_len(rb_struct_s_members((VALUE)NSMapGet(knownStructs, (void*)inStructHash)));
                               
    inStruct = (ffi_type *)malloc(sizeof(ffi_type));
    inStruct->size = 0;
    inStruct->alignment = 0;
    inStruct->type = FFI_TYPE_STRUCT;
    inStruct->elements = malloc((inStructCount + 1) * sizeof(ffi_type *));
    
    while (*type != _C_STRUCT_E) {
      inStruct->elements[inStructIndex++] = rb_objc_ffi_type_for_type(type);
      type = objc_skip_typespec(type);
    }
    inStruct->elements[inStructIndex] = NULL;

    return inStruct;
  }

  switch (*type) {
  case _C_ID:
  case _C_CLASS:
  case _C_SEL:
  case _C_CHARPTR:
  case _C_PTR:    
    return &ffi_type_pointer;
  case _C_BOOL:
  case _C_UCHR:
    return &ffi_type_uchar;
  case _C_CHR:
    return &ffi_type_schar;
  case _C_SHT:
    return &ffi_type_sshort;
  case _C_USHT:
    return &ffi_type_ushort;
  case _C_INT:
    return &ffi_type_sint;
  case _C_UINT:
    return &ffi_type_uint;
  case _C_LNG:
    return &ffi_type_slong;
  case _C_LNG_LNG: 
    return &ffi_type_sint64;
  case _C_ULNG:
    return &ffi_type_ulong;
  case _C_ULNG_LNG: 
    return &ffi_type_uint64;    
  case _C_FLT:
    return &ffi_type_float;
  case _C_DBL:
    return &ffi_type_double;
  case _C_VOID:
    return &ffi_type_void;      
  default:
    return NULL;
  }
}

ffi_status
rb_objc_build_closure_cif(ffi_cif *cif, const char *objcTypes)
{
  NSMethodSignature *signature;
  unsigned int nbArgs;
  const char *type;
  ffi_type **arg_types;
  ffi_type *ret_type;
  unsigned int i;
  
  signature = [NSMethodSignature signatureWithObjCTypes:objcTypes];
  nbArgs = (unsigned int)[signature numberOfArguments];

  arg_types = malloc(sizeof(ffi_type*) * nbArgs);
  memset(arg_types, 0, sizeof(ffi_type*) * nbArgs);

  for (i=0;i<nbArgs;i++) {
    type = [signature getArgumentTypeAtIndex:i];
    arg_types[i] = rb_objc_ffi_type_for_type(type);
  }
        
  type = [signature methodReturnType];
  ret_type = rb_objc_ffi_type_for_type(type);

  return ffi_prep_cif(cif, FFI_DEFAULT_ABI, nbArgs, ret_type, arg_types);
}

void
rb_objc_proxy_handler(ffi_cif *cif, void *ret, void **args, void *user_data) {
  @autoreleasepool {
    id val;
    SEL sel;
    VALUE rubyObject;
    VALUE rubyRetVal;
    char *rubyMethodName;
    VALUE *rubyArgs;
    NSMethodSignature	*signature;
    unsigned int i;
    const char *type;
    void *data;

    val = *(id*)args[0];
    sel = *(SEL*)args[1];
    signature = [NSMethodSignature signatureWithObjCTypes:(const char*)user_data];

    rubyMethodName = rb_objc_sel_to_method(sel);
    rubyObject = (VALUE) NSMapGet(knownObjects,(void *)val);
    if (rubyObject == Qfalse) {
      Class retClass = [val classForCoder] ?: [val class];
      VALUE rb_class = (VALUE) NSMapGet(knownClasses, (void *)retClass);
      if (rb_class == Qfalse) {
        rb_class = rb_objc_register_class_from_objc(retClass);
      }
      rubyObject = Data_Wrap_Struct(rb_class, 0, rb_objc_release, val);
      NSMapInsertKnownAbsent(knownObjects, (void*)val, (void*)rubyObject);
    }    
    rubyArgs = malloc((cif->nargs - 2) * sizeof(VALUE));

    for (i=2;i<cif->nargs;i++) {
      type = [signature getArgumentTypeAtIndex:i];
      rb_objc_convert_to_rb(args[i], 0, type, &rubyArgs[i-2], NO);
    }

    rubyRetVal = rb_funcallv(rubyObject, rb_intern(rubyMethodName), cif->nargs - 2, rubyArgs);

    if ([signature methodReturnLength]) {
      type = [signature methodReturnType];
      size_t ret_len = MAX(sizeof(long), [signature methodReturnLength]);
      data = alloca(ret_len);

      rb_objc_convert_to_objc(rubyRetVal, &data, 0, type);

      *(ffi_arg*)ret = *(ffi_arg*)data;
    }
  
    free(rubyArgs);
    free(rubyMethodName);
  }
}

const char *
rb_objc_types_for_selector(SEL sel, size_t nbArgs) {
  char *objcTypes;
  unsigned long hash;
  size_t i;

  hash = rb_objc_hash(sel_getName(sel));
  objcTypes = NSMapGet(knownProtocols, (void*)hash);

  if (objcTypes == NULL) {
    objcTypes = NSMapGet(knownProtocols, (void*)nbArgs);
  }

  if (objcTypes == NULL) {
    objcTypes = malloc(sizeof(char) * (nbArgs + 4));
    
    objcTypes[0] = _C_ID;
    objcTypes[1] = _C_ID;
    objcTypes[2] = _C_SEL;
    for (i=0;i<nbArgs;i++) {
      objcTypes[3+i] = _C_ID;
    }
    objcTypes[3+i] = '\0';
    
    NSMapInsertKnownAbsent(knownProtocols, (void*)nbArgs, objcTypes);
  }

  return objcTypes;
}

BOOL
rb_objc_convert_to_objc(VALUE rb_thing,void **data, size_t offset, const char *type)
{
  BOOL ret = YES;
  int idx = 0;
  BOOL inStruct = NO;
  
 
  // If Ruby gave the NIL value then bypass all the rest
  // (FIXME?) Check if it should be handled differently depending
  //  on the ObjC type.
  if(NIL_P(rb_thing)) {
    **(id**)data = (id) nil;
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
    where = *((uint8_t**)data) + offset;
        
    offset += tsize;

    NSDebugLog(@"Converting Ruby value (%p, type 0x%02x) to ObjC value (%p, encoding %c)",
               (void*)rb_thing, TYPE(rb_thing), where, *type);

    if (inStruct) {
      rb_val = rb_struct_aref(rb_thing, INT2NUM(idx++));
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
          if (rb_obj_is_kind_of(rb_val, rb_cTime) == Qtrue) {
            *(NSDate**)where = [NSDate dateWithRubyTime:rb_val];
          }
          else {
            Data_Get_Struct(rb_val, void, *(id*)where);
          }
          break;

        case T_SYMBOL:
          *(NSString**)where = [NSString stringWithRubySymbol:rb_val];
          break;
          
        case T_STRING:
          *(NSString**)where = [NSString stringWithRubyString:rb_val];
          break;
          
        case T_CLASS:
          *(Class*)where = (Class)NUM2LL(rb_iv_get(rb_val, "@objc_class"));
          break;
        case T_OBJECT:
          /* Ruby sends a Ruby class or a ruby object. Automatically register
             an ObjC proxy class. It is very likely that we'll need it in the future
             (e.g. typical for setDelegate method call) */
          Data_Get_Struct(rb_val, void, *(id*)where);
          NSDebugLog(@"Wrapping Ruby Object of type: 0x%02x (ObjC object at %p)", TYPE(rb_val), where);
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
        case T_TRUE:
          *(NSNumber**)where = [NSNumber numberWithRubyBool:rb_val];
          break;

        default:
          ret = NO;
          break;
                
        }
      break;

    case _C_SEL:
      if (TYPE(rb_val) == T_STRING) {
        *(SEL*)where = sel_getUid(rb_string_value_cstr(&rb_val));
      } else if (TYPE(rb_val) == T_SYMBOL) {
        VALUE rb_string = rb_sym_to_s(rb_val);
        *(SEL*)where = sel_getUid(rb_string_value_cstr(&rb_string));
      } else {
        ret = NO;
      }
      break;

    case _C_BOOL:
      if (TYPE(rb_val) == T_TRUE)
        *(BOOL*)where = YES;
      else if (TYPE(rb_val) == T_FALSE)
        *(BOOL*)where = NO;
      else
        ret = NO;
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
      else if (TYPE(rb_val) == T_TRUE)
        *(int*)where = YES;
      else if (TYPE(rb_val) == T_FALSE)
        *(int*)where = NO;
      else
        ret = NO;	  
      break;

    case _C_UINT:
      if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM)
        *(unsigned int*)where = (unsigned int) NUM2UINT(rb_val);
      else if (TYPE(rb_val) == T_TRUE)
        *(unsigned int*)where = YES;
      else if (TYPE(rb_val) == T_FALSE)
        *(unsigned int*)where = NO;
      else
        ret = NO;
      break;

    case _C_LNG:
      if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )
        *(long*)where = (long) NUM2LONG(rb_val);
      else if (TYPE(rb_val) == T_TRUE)
        *(long*)where = YES;
      else if (TYPE(rb_val) == T_FALSE)
        *(long*)where = NO;
      else
        ret = NO;	  	
      break;

    case _C_ULNG:
      if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )
        *(unsigned long*)where = (unsigned long) NUM2ULONG(rb_val);
      else if (TYPE(rb_val) == T_TRUE)
        *(unsigned long*)where = YES;
      else if (TYPE(rb_val) == T_FALSE)
        *(unsigned long*)where = NO;
      else
        ret = NO;	  	
      break;

    case _C_LNG_LNG:
      if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )
        *(long long*)where = (long long) NUM2LL(rb_val);
      else if (TYPE(rb_val) == T_TRUE)
        *(long long*)where = YES;
      else if (TYPE(rb_val) == T_FALSE)
        *(long long*)where = NO;
      else
        ret = NO;	  	
      break;

    case _C_ULNG_LNG:
      if (TYPE(rb_val) == T_FIXNUM || TYPE(rb_val) == T_BIGNUM )              
        *(unsigned long long*)where = (unsigned long long) NUM2ULL(rb_val);
      else if (TYPE(rb_val) == T_TRUE)
        *(unsigned long long*)where = YES;
      else if (TYPE(rb_val) == T_FALSE)
        *(unsigned long long*)where = NO;
      else
        ret = NO;	  	
      break;

    case _C_FLT:
      if ( (TYPE(rb_val) == T_FLOAT) || 
           (TYPE(rb_val) == T_FIXNUM) ||
           (TYPE(rb_val) == T_BIGNUM) ) {

        // FIXME: possible overflow but don't know (yet) how to check it ??
        *(float*)where = (float) NUM2DBL(rb_val);
        NSDebugLog(@"Converting ruby value to float: %f", *(float*)where);
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
        NSDebugLog(@"Converting ruby value to double: %lf", *(double*)where);
      }
      else
        ret = NO;	  	
      break;

    case _C_CHARPTR:
      // Inspired from the Guile interface
      if (TYPE(rb_val) == T_STRING) {
        NSMutableData	*d;
        char *s;
        size_t l;
            
        s = rb_string_value_cstr(&rb_val);
        l = strlen(s)+1;
        d = [NSMutableData dataWithBytesNoCopy:s length:l freeWhenDone:NO];
        *(char**)where = (char*)[d mutableBytes];
      } else if (TYPE(rb_val) == T_DATA) {
        // I guess this is the right thing to do. Pass the
        // embedded ObjC as a blob
        Data_Get_Struct(rb_val, char, *(char**)where);
      } else {
        ret = NO;
      }
      break;
   

    case _C_PTR:
      // Inspired from the Guile interface. Same as char_ptr above
      if (TYPE(rb_val) == T_STRING) {
        NSMutableData	*d;
        char *s;
        size_t l;
            
        s = rb_string_value_cstr(&rb_val);
        l = strlen(s);
        d = [NSMutableData dataWithBytesNoCopy:s length:l freeWhenDone:NO];
        *(void**)where = (void*)[d mutableBytes];
      } else if (rb_obj_is_kind_of(rb_val, rb_cRigsPtr) == Qtrue) {
        struct rb_objc_ptr *dp;
        dp = (struct rb_objc_ptr*)DATA_PTR(rb_val);
        *(void**)data = &(dp->cptr);
      } else if (TYPE(rb_val) == T_DATA) {              
        if (strncmp(type, "^{", 2) == 0) {
          // Assume toll-free bridge
          Data_Get_Struct(rb_val, void, *(id*)where);
        }
        else {
          Data_Get_Struct(rb_val, void, *(void**)where);
        }
      } else {
        ret = NO;
      }
      break;


    case _C_STRUCT_B: 
      {
        // We are attacking a new embedded structure in a structure
        if (TYPE(rb_val) == T_STRUCT) {
          if ( rb_objc_convert_to_objc(rb_val, &where, 0, type) == NO) {     
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
    rb_raise(rb_eTypeError, "don't know how to convert Ruby (type 0x%02x) from ObjC (encoding %c)",
             TYPE(rb_thing), *type);
  }


  return ret;
  
}


BOOL
rb_objc_convert_to_rb(void *data, size_t offset, const char *type, VALUE *rb_val_ptr, BOOL autoconvert)
{
  BOOL ret = YES;
  VALUE rb_class;
  BOOL inStruct = NO;
  unsigned long inStructHash;
  VALUE end = Qnil;

  if (*type == _C_STRUCT_B) {

    NSDebugLog(@"Starting conversion of ObjC structure %s to Ruby value", type);

    inStruct = YES;
    inStructHash = HASH_SEED;
    while (*type != _C_STRUCT_E && *type++ != '=') {
      if (*type == '=') continue;
      inStructHash = ((inStructHash << HASH_BITSHIFT) + inStructHash) + (*type);
    }
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

    NSGetSizeAndAlignment(type, &tsize, &align);
      
    offset = ROUND(offset, align);
    where = (uint8_t*)data + offset;

    NSDebugLog(@"Converting ObjC value (%p, encoding %c) to Ruby value",
               where, *type);
        
    offset += tsize;

    switch (*type)
      {
      case _C_ID: {
        id val = *(id*)where;
        // Check if the ObjC object is already wrapped into a Ruby object
        // If so do not create a new object. Return the existing one
        if ( (rb_val = (VALUE) NSMapGet(knownObjects,(void *)val)) )  {

          NSDebugLog(@"ObjC object already wrapped in an existing Ruby value (%p)", (void*)rb_val);

        } else if (val == nil) {
                  
          rb_val = Qnil;
                  
        } else if ( autoconvert && [val isKindOfClass:[NSString class]] ) {
          rb_val = [val getRubyObject];
        } else if ( autoconvert && [val isKindOfClass:[NSNumber class]] ) {
          rb_val = [val getRubyObject];
        } else if ( autoconvert && [val isKindOfClass:[NSArray class]] ) {
          rb_val = [val getRubyObject];
        } else if ( autoconvert && [val isKindOfClass:[NSDictionary class]] ) {
          rb_val = [val getRubyObject];
        } else if ( autoconvert && [val isKindOfClass:[NSDate class]] ) {
          rb_val = [val getRubyObject];
        } else {
                  
          /* Retain the value otherwise ObjC releases it and Ruby crashes
             It's Ruby garbage collector job to indirectly release the ObjC 
             object by calling rb_objc_release() */
          if ([val respondsToSelector: @selector(retain)]) {
            [val retain];
          }

          Class retClass = [val classForCoder] ?: [val class];
          if (retClass != [val class] && strncmp(object_getClassName(val), "NSConcrete", 10) == 0) { 
            retClass = [val class];
          }
                  
          NSDebugLog(@"Class of arg transmitted to Ruby = %@", NSStringFromClass(retClass));

          rb_class = (VALUE) NSMapGet(knownClasses, (void *)retClass);
                  
          // if the class of the returned object is unknown to Ruby
          // then register the new class with Ruby first
          if (rb_class == Qfalse) {
            rb_class = rb_objc_register_class_from_objc(retClass);
          }
          rb_val = Data_Wrap_Struct(rb_class,0,rb_objc_release,val);
          NSMapInsertKnownAbsent(knownObjects, (void*)val, (void*)rb_val);
        }
      }
        break;

      case _C_CHARPTR: 
        {
          // Convert char * to ruby String
          char *val = *(char **)where;
          if (val)
            rb_val = rb_str_new_cstr(val);
          else 
            rb_val = Qnil;
        }
        break;

      case _C_PTR:
        {
          if (strncmp(type, "^{", 2) == 0) {
            // Assume toll-free bridge
              
            id val = *(id*)where;
            if ([val respondsToSelector: @selector(retain)]) {
              [val retain];
            }

            Class retClass = [val classForCoder] ?: [val class];
                  
            NSDebugLog(@"Class of arg transmitted to Ruby = %@", NSStringFromClass(retClass));

            rb_class = (VALUE) NSMapGet(knownClasses, (void *)retClass);
                  
            // if the class of the returned object is unknown to Ruby
            // then register the new class with Ruby first
            if (rb_class == Qfalse) {
              rb_class = rb_objc_register_class_from_objc(retClass);
            }
            rb_val = Data_Wrap_Struct(rb_class,0,rb_objc_release,val);
            NSMapInsertKnownAbsent(knownObjects, (void*)val, (void*)rb_val);
          }
          else {
            // TODO: return pointers as ObjRuby::Pointer
            // for now a pointer is returned as its integer value
            rb_val = LL2NUM((long long) where);
          }
        }
        break;

      case _C_BOOL:
        if ( *(BOOL *)where == YES)
          rb_val = Qtrue;
        else if ( *(BOOL *)where == NO)
          rb_val = Qfalse;
        else
          rb_val = Qnil;
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
        rb_val = rb_float_new((double)(*(float*)where));
        break;

      case _C_DBL:
        rb_val = rb_float_new(*(double*)where);
        break;

      case _C_CLASS:
        {
          Class val = *(Class*)where;
            
          NSDebugLog(@"ObjC Class = %@", NSStringFromClass([val classForCoder]));
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
            
          NSDebugLog(@"ObjC Selector = %s", sel_getName(val));

          rb_val = rb_str_new_cstr(sel_getName(val));
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
        end = rb_ary_new();
        rb_ary_push(end, rb_val);
        *rb_val_ptr = end;
      } else {
        // Next component in the same structure. Append it to 
        // the end of the running Ruby array
        rb_ary_push(end, rb_val);
      }



    } else {
      // We are not in a C structure so simply return the
      // Ruby value
      *rb_val_ptr = rb_val;
    }
     
    // skip the type of the component we have just processed
    type = (char*)objc_skip_typespec(type);

 
 
  } while (inStruct && *type != _C_STRUCT_E);

  if (end != Qnil && NSMapGet(knownStructs, (void*)inStructHash) != NULL) {
    *rb_val_ptr = rb_struct_alloc((VALUE)NSMapGet(knownStructs, (void*)inStructHash), end);
  }

  NSDebugLog(@"End of ObjC to Ruby conversion");
    
  return ret;

}

NSMethodSignature*
rb_objc_signature_with_format_string(NSMethodSignature *signature, const char *formatString, int nbArgsExtra)
{
  char objcTypes[128];
  uint8_t objcTypesIndex;
  size_t formatStringLength;
  const char *type;
  size_t nbArgs;
  size_t i;

  nbArgs = [signature numberOfArguments];
  objcTypesIndex = 0;
  
  type = [signature methodReturnType];  
  while (*type) {
    objcTypes[objcTypesIndex++] = *type++;
  }

  for(i=0; i<nbArgs; i++) {
    type = [signature getArgumentTypeAtIndex:i];
    while (*type) {
      objcTypes[objcTypesIndex++] = *type++;
    }
  }

  formatStringLength = strlen(formatString);
  i = 0;
  
  while (i < formatStringLength) {
    if (formatString[i++] != '%') continue;
    if (i < formatStringLength && formatString[i] == '%') {
      i++;
      continue;
    }
    objcTypes[objcTypesIndex] = '\0';
    while (i < formatStringLength) {
      switch (formatString[i++]) {
      case 'd':
      case 'i':
      case 'o':
      case 'u':
      case 'x':
      case 'X':
      case 'c':
      case 'C':
        objcTypes[objcTypesIndex] = _C_INT;
        break;
      case 'D':
      case 'O':
      case 'U':
        objcTypes[objcTypesIndex] = _C_LNG;
        break;
      case 'f':       
      case 'F':
      case 'e':       
      case 'E':
      case 'g':       
      case 'G':
      case 'a':
      case 'A':
        objcTypes[objcTypesIndex] = _C_DBL;
        break;
      case 's':
      case 'S':
        objcTypes[objcTypesIndex] = _C_CHARPTR;
        break;
      case 'p':
        objcTypes[objcTypesIndex] = _C_PTR;
        break;
      case '@':
        objcTypes[objcTypesIndex] = _C_ID;
        break;            
      }
      if (objcTypes[objcTypesIndex] != '\0') {
        objcTypesIndex++;
        if (--nbArgsExtra < 0) {
          rb_raise(rb_eArgError, "too many tokens in the format string '%s' for the given argument(s)", formatString);
        }
        break;
      }
    }
  }

  while (nbArgsExtra-- > 0) {
    objcTypes[objcTypesIndex++] = _C_ID;
  }
  objcTypes[objcTypesIndex] = '\0';

  return [NSMethodSignature signatureWithObjCTypes:objcTypes];
}

void
rb_objc_block_handler(ffi_cif *cif, void *ret, void **args, void *user_data) {
  struct rb_objc_block *block;
  const char *objcTypes;
  NSMethodSignature *signature;
  NSUInteger nbArgs;
  const char *type;
  NSUInteger i;
  void *data;
  VALUE rb_array;
  VALUE rb_arg;
  VALUE rb_proc;
  VALUE rb_ret;

  block = *(struct rb_objc_block **)args[0];
  objcTypes = block->descriptor->signature;
  signature = [NSMethodSignature signatureWithObjCTypes:objcTypes];
  nbArgs = [signature numberOfArguments];
  rb_array = rb_ary_new_capa(nbArgs - 1);

  for (i=1;i<nbArgs;i++) {
    type = [signature getArgumentTypeAtIndex:i];
    rb_objc_convert_to_rb(args[i], 0, type, &rb_arg, NO);
    rb_ary_push(rb_array, rb_arg);
  }

  rb_proc = *(VALUE*)user_data;
  rb_ret = rb_proc_call(rb_proc, rb_array);  

  if([signature methodReturnLength]) {
    type = [signature methodReturnType];
    size_t ret_len = MAX(sizeof(long), [signature methodReturnLength]);
    data = alloca(ret_len);

    rb_objc_convert_to_objc(rb_ret, &data, 0, type);

    *(ffi_arg*)ret = *(ffi_arg*)data;
  }
}

VALUE
rb_objc_dispatch(id rcv, const char *method, NSMethodSignature *signature, int rigs_argc, VALUE *rigs_argv)
{
  @autoreleasepool {
    void *sym;
    unsigned long hash;
    int nbArgs;
    int nbArgsExtra;
    int nbArgsAdjust;
    int i;
    const char *type;
    void *data;
    void **args;
    VALUE rb_arg;
    VALUE rb_retval;
    ffi_cif cif;
    ffi_type **arg_types;
    ffi_type *ret_type;
    ffi_closure *closure;
    ffi_status status;
    void *closurePtr;
    struct rb_objc_block *block;
    ffi_cif closureCif;

    if (rcv != nil) {
      // TODO: perhaps check [rcv methodForSelector:sel] for IMP
      nbArgsAdjust = 2;
      switch(*(signature.methodReturnType)) {
#ifndef __aarch64__
      case _C_STRUCT_B:
        sym = objc_msgSend_stret;
        break;
#endif      
      default:
        sym = objc_msgSend;
        break;
      }
    }
    else {
      nbArgsAdjust = 0;
      sym = dlsym(RTLD_DEFAULT, method);
    }

    if (!sym) {
      return Qnil;
    }

    hash = rb_objc_hash(method);

    nbArgs = (int)[signature numberOfArguments];
    nbArgsExtra = rigs_argc - (nbArgs - nbArgsAdjust);
  
    if (nbArgsExtra < 0) {
      rb_raise(rb_eArgError, "wrong number of arguments (%d for %d)", rigs_argc, nbArgs - nbArgsAdjust);
    }
  
    if (nbArgsExtra > 0) {
      NSInteger formatStringIndex;
      const char *formatString;
      
      formatStringIndex = (NSInteger)NSMapGet(knownFormatStrings, (void*)hash) - 1;
      if (formatStringIndex != -1 && TYPE(rigs_argv[formatStringIndex]) == T_STRING) {
        formatString = rb_string_value_cstr(&rigs_argv[formatStringIndex]);
      }
      else {
        formatString = "";
      }
      signature = rb_objc_signature_with_format_string(signature, formatString, nbArgsExtra);
      nbArgs = (int)[signature numberOfArguments];
    }

    args = alloca(sizeof(void*) * nbArgs);
    arg_types = alloca(sizeof(ffi_type*) * nbArgs);

    memset(args, 0, sizeof(void*) * nbArgs);
    memset(arg_types, 0, sizeof(ffi_type*) * nbArgs);

    for (i=0;i<nbArgsAdjust;i++) {
      type = [signature getArgumentTypeAtIndex:i];
      NSUInteger tsize;
      NSGetSizeAndAlignment(type, &tsize, NULL);
      data = alloca(tsize);
      switch (i) {
      case 0:
        *(id*)data = rcv;
        break;
      case 1:
        *(SEL*)data = sel_getUid(method);
        break;
      }
      args[i] = data;
      arg_types[i] = rb_objc_ffi_type_for_type(type);
    }

    block = NULL;
    closure = NULL;
    for (i=nbArgsAdjust;i<nbArgs;i++) {
      type = [signature getArgumentTypeAtIndex:i];
      if (strcmp(type, "@?") == 0) {
        const char* blockObjcTypes = NSMapGet(knownBlocks, (void*)(hash + i - nbArgsAdjust));
        if (blockObjcTypes && rb_objc_build_closure_cif(&closureCif, blockObjcTypes) == FFI_OK) {
          closure = ffi_closure_alloc(sizeof(ffi_closure), &closurePtr);
          if (ffi_prep_closure_loc(closure, &closureCif, rb_objc_block_handler, &rigs_argv[i-nbArgsAdjust], closurePtr) == FFI_OK) {
            block = (struct rb_objc_block*)malloc(sizeof(struct rb_objc_block));
            block->isa = &_NSConcreteStackBlock;
            block->flags = 1 << 30; // BLOCK_HAS_SIGNATURE
            block->reserved = 0;
            block->invoke = closurePtr;
            block->descriptor = (struct rb_objc_block_descriptor*)malloc(sizeof(struct rb_objc_block_descriptor));
            block->descriptor->reserved = 0;
            block->descriptor->size = sizeof(struct rb_objc_block);
            block->descriptor->signature = blockObjcTypes;
          }
        }

        NSUInteger tsize;
        NSGetSizeAndAlignment(type, &tsize, NULL);
        data = alloca(tsize);
        *(struct rb_objc_block**)data = block;
        args[i] = data;
        arg_types[i] = rb_objc_ffi_type_for_type(type);
      }
      else {
        NSUInteger tsize;
        NSGetSizeAndAlignment(type, &tsize, NULL);
        void *tdata = alloca(tsize);
        rb_objc_convert_to_objc(rigs_argv[i-nbArgsAdjust], &tdata, 0, type);
        args[i] = tdata;
        arg_types[i] = rb_objc_ffi_type_for_type(type);
      }
    }

    type = [signature methodReturnType];

    ret_type = rb_objc_ffi_type_for_type(type);
    if (ret_type != &ffi_type_void) {
      size_t ret_len = MAX(sizeof(long), [signature methodReturnLength]);
      data = alloca(ret_len);
    }
    else {
      data = NULL;
    }

    status = nbArgsExtra > 0 ?
      ffi_prep_cif_var(&cif, FFI_DEFAULT_ABI, nbArgs - nbArgsExtra, nbArgs, ret_type, arg_types) :
      ffi_prep_cif(&cif, FFI_DEFAULT_ABI, nbArgs, ret_type, arg_types);

    rb_retval = Qnil;
    if (status == FFI_OK) {
      ffi_call(&cif, FFI_FN(sym), (ffi_arg *)data, args);

      for (i=0;i<rigs_argc;i++) {
        rb_arg = rigs_argv[i];
        if (rb_obj_is_kind_of(rb_arg, rb_cRigsPtr) == Qtrue) {
          rb_objc_ptr_retain(rb_arg);
        }
      }
    
      if (ret_type != &ffi_type_void) {
        rb_objc_convert_to_rb(data, 0, type, &rb_retval, NO);
      }
    }

    if (closure != NULL) {
      ffi_closure_free(closure);
    }
    if (block != NULL) {
      free(block);
    }
  
    return rb_retval;
  }
}

VALUE
rb_objc_send(int rigs_argc, VALUE *rigs_argv, VALUE rb_self)
{
  @autoreleasepool {
    const char *method;
    int our_argc;
    VALUE *our_argv;
    id rcv;
    SEL sel;
    NSMethodSignature *signature;

    method = rb_id2name(rb_frame_this_func());
    our_argc = rigs_argc;
    our_argv = rigs_argv;
  
    if (rb_block_given_p()) {
      our_argc = rigs_argc + 1;
      our_argv = alloca(our_argc * sizeof(VALUE));
      for (int i=0;i<rigs_argc;i++) {
        our_argv[i] = rigs_argv[i];
      }
      our_argv[our_argc-1] = rb_block_proc();
    }

    /* determine the receiver type - Class or instance ? */
    switch (TYPE(rb_self)) {
    case T_DATA:
      Data_Get_Struct(rb_self, void, rcv);
      NSDebugLog(@"Self is Ruby instance (%p) of %@ (%p): %@)",
                 (void*)rb_self, NSStringFromClass([rcv classForCoder]), DATA_PTR(rb_self), rcv);
      break;
    case T_CLASS:
      rcv = (Class) NUM2LL(rb_iv_get(rb_self, "@objc_class"));
      NSDebugLog(@"Self is Ruby class (%p): %@", (void*)rb_self, NSStringFromClass([rcv classForCoder]));
      break;
    default:
      rb_raise(rb_eTypeError, "type 0x%02x not valid self value", TYPE(rb_self));
      break;
    }

    sel = rb_objc_method_to_sel(method, our_argc);
    signature = [rcv methodSignatureForSelector:sel];

    if (!signature) {
      return Qnil;
    }

    return rb_objc_dispatch(rcv, sel_getName(sel), signature, our_argc, our_argv);
  }
}

VALUE
rb_objc_invoke(int rigs_argc, VALUE *rigs_argv, VALUE rb_self)
{
  @autoreleasepool {
    const char *method;
    unsigned long hash;
    const char *objcTypes;
    NSMethodSignature *signature;
    
    method = rb_id2name(rb_frame_this_func());
    hash = rb_objc_hash(method);
    objcTypes = NSMapGet(knownFunctions, (void*)hash);

    if (!objcTypes) {
      return Qnil;
    }
    
    signature = [NSMethodSignature signatureWithObjCTypes:objcTypes];

    if (!signature) {
      return Qnil;
    }

    return rb_objc_dispatch(nil, method, signature, rigs_argc, rigs_argv);
  }  
}

VALUE
rb_objc_description(VALUE rb_self)
{
  id rcv;

  Data_Get_Struct(rb_self, void, rcv);

  return rb_str_new_cstr([[rcv description] UTF8String]);
}

VALUE
rb_objc_debug_description(VALUE rb_self)
{
  id rcv;

  Data_Get_Struct(rb_self, void, rcv);

  return rb_str_new_cstr([[rcv debugDescription] UTF8String]);
}

VALUE
rb_objc_get_ruby_object(VALUE rb_self)
{
  id rcv;

  Data_Get_Struct(rb_self, void, rcv);

  return [rcv getRubyObject];
}

VALUE
rb_objc_get_ruby_int(VALUE rb_self)
{
  id rcv;

  Data_Get_Struct(rb_self, void, rcv);

  return [rcv getRubyInteger];
}

VALUE
rb_objc_get_ruby_float(VALUE rb_self)
{
  id rcv;

  Data_Get_Struct(rb_self, void, rcv);

  return [rcv getRubyFloat];
}

unsigned int rb_objc_register_instance_methods(Class objc_class, VALUE rb_class)
{
  SEL mthSel;
  char *mthRubyName;
  unsigned int imth_cnt;
  unsigned int i;
  Method *methods;

  //Store the ObjcC Class id in the @@objc_class Ruby Class Variable
  rb_iv_set(rb_class, "@objc_class", LL2NUM((long long)objc_class));
    
  /* Define all Ruby Instance methods for this Class */
  methods = class_copyMethodList(objc_class, &imth_cnt);

  for (i=0;i<imth_cnt;i++) {
    mthSel = method_getName(methods[i]);
    mthRubyName = rb_objc_sel_to_method(mthSel);
      
    rb_define_method(rb_class, mthRubyName, rb_objc_send, -1);

    free(mthRubyName);
  }

  free(methods);

  return imth_cnt;    
}

unsigned int rb_objc_register_class_methods(Class objc_class, VALUE rb_class)
{
  SEL mthSel;
  char *mthRubyName;
  Class objc_meta_class;
  unsigned int cmth_cnt;
  unsigned int i;
  Method *methods;

  objc_meta_class = objc_getMetaClass(class_getName(objc_class));
    
  /* Define all Ruby Class (singleton) methods for this Class */
  methods = class_copyMethodList(objc_meta_class, &cmth_cnt);

  for (i=0;i<cmth_cnt;i++) {
    mthSel = method_getName(methods[i]);
    mthRubyName = rb_objc_sel_to_method(mthSel);
      
    rb_define_singleton_method(rb_class, mthRubyName, rb_objc_send, -1);

    free(mthRubyName);
  }

  free(methods);

  // Redefine the new method to point to our special rb_objc_new function
  rb_undef_method(CLASS_OF(rb_class),"new");
  rb_define_singleton_method(rb_class, "new", rb_objc_new, -1);

  return cmth_cnt;
}

void
rb_objc_register_protocol_from_objc(const char *protocolName)
{
  Protocol *proto;
  struct objc_method_description *descriptions;
  unsigned int i;
  unsigned int numDescriptions;
  unsigned long hash;
  char *data;
  const char *objcTypes;

  proto = objc_getProtocol(protocolName);

  if (proto == NULL) {
    NSDebugLog(@"Could not find objc protocol for %s", protocolName);
    return;
  }

  descriptions = protocol_copyMethodDescriptionList(proto, NO, YES, &numDescriptions);

  for (i=0;i<numDescriptions;i++) {
    hash = rb_objc_hash(sel_getName(descriptions[i].name));
    if (!NSMapGet(knownProtocols, (void*)hash)) {
      objcTypes = rb_objc_sanitize_objc_types(descriptions[i].types);
      data = malloc(sizeof(char) * (strlen(objcTypes) + 1));
      strcpy(data, objcTypes);
      NSMapInsertKnownAbsent(knownProtocols, (void*)hash, (void*)data);
    }
  }

  free(descriptions);
}

void
rb_objc_register_function_from_objc(const char *name, const char *objcTypes)
{
  char *data;
  unsigned long hash = rb_objc_hash(name);

  data = malloc(sizeof(char) * (strlen(objcTypes) + 1));
  strcpy(data, objcTypes);
  
  NSMapInsertKnownAbsent(knownFunctions, (void*)hash, (void*)data);

  rb_define_module_function(rb_mRigs, name, rb_objc_invoke, -1);
}


void
rb_objc_register_constant_from_objc(const char *name, const char *type)
{
  void *data;
  VALUE rb_retval;
  
  data = dlsym(RTLD_DEFAULT, name);

  if (data != NULL) {
    if (rb_objc_convert_to_rb(data, 0, type, &rb_retval, YES)) {
      rb_define_const(rb_mRigs, name, rb_retval);
    }
  }
}

void
rb_objc_register_float_from_objc(const char *name, double value)
{
  VALUE rb_float;

  rb_float = DBL2NUM(value);
  
  rb_define_const(rb_mRigs, name, rb_float);
}

void
rb_objc_register_integer_from_objc(const char *name, long long value)
{
  VALUE rb_integer;

  rb_integer = LL2NUM(value);
  
  rb_define_const(rb_mRigs, name, rb_integer);
}

void
rb_objc_register_block_from_objc(const char *selector, size_t index, const char *objcTypes)
{
  unsigned long hash;
  char *data;

  hash = rb_objc_hash(selector) + index;

  if (!NSMapGet(knownBlocks, (void*)hash)) {
    data = malloc(sizeof(char) * (strlen(objcTypes) + 1));
    strcpy(data, objcTypes);
    NSMapInsertKnownAbsent(knownBlocks, (void*)hash, (void*)data);
  }
}

void
rb_objc_register_format_string_from_objc(const char *selector, size_t index)
{
  unsigned long hash;

  hash = rb_objc_hash(selector);

  if (!NSMapGet(knownFormatStrings, (void*)hash)) {
    NSMapInsertKnownAbsent(knownFormatStrings, (void*)hash, (void*)(index + 1));
  }
}


void
rb_objc_register_struct_from_objc(const char *key, const char *name, const char *args[], size_t argCount)
{
  VALUE rb_struct;
  unsigned long hash = rb_objc_hash(key);
  
  if (NSMapGet(knownStructs, (void*)hash)) {
    return;
  }
  
  switch(argCount) {
  case 1:
    rb_struct = rb_struct_define_under(rb_mRigs, name, args[0], NULL);
    break;
  case 2:
    rb_struct = rb_struct_define_under(rb_mRigs, name, args[0], args[1], NULL);
    break;
  case 3:
    rb_struct = rb_struct_define_under(rb_mRigs, name, args[0], args[1], args[2], NULL);
    break;
  case 4:
    rb_struct = rb_struct_define_under(rb_mRigs, name, args[0], args[1], args[2], args[3], NULL);
    break;
  case 5:
    rb_struct = rb_struct_define_under(rb_mRigs, name, args[0], args[1], args[2], args[3], args[4], NULL);
    break;
  case 6:
    rb_struct = rb_struct_define_under(rb_mRigs, name, args[0], args[1], args[2], args[3], args[4], args[5], NULL);
    break;
  default:
    rb_raise(rb_eTypeError, "unsupported struct '%s' with argument size: %zu", name, argCount);
    break;
  }

  NSMapInsertKnownAbsent(knownStructs, (void*)hash, (void*)rb_struct);
}


VALUE
rb_objc_register_class_from_objc (Class objc_class)
{

  @autoreleasepool {
    const char *cname = class_getName(objc_class);

    Class objc_super_class = class_getSuperclass(objc_class);
    VALUE rb_class;
    VALUE rb_super_class = Qnil;
    unsigned int imth_cnt;
    unsigned int cmth_cnt;

    NSDebugLog(@"Request to register ObjC Class %s (ObjC id = %p)", cname, objc_class);

    // If this class has already been registered then return existing
    // Ruby class VALUE
    rb_class = (VALUE) NSMapGet(knownClasses, (void *)objc_class);

    if (rb_class != Qfalse) {
      NSDebugLog(@"Class %s already registered (VALUE %p)", cname, (void*)rb_class);
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
    rb_undef_alloc_func(rb_class);

    cmth_cnt = rb_objc_register_class_methods(objc_class, rb_class);
    imth_cnt = rb_objc_register_instance_methods(objc_class, rb_class);

    NSDebugLog(@"%d instance and %d class methods defined for class %s", imth_cnt, cmth_cnt, cname);

    // Extend any extra Ruby specific support to Objective-C classes
    if (objc_class == [NSObject class]) {
      rb_define_alias(rb_class, "==", "isEqual");
      rb_define_method(rb_class, "to_s", rb_objc_description, 0);
      rb_define_method(rb_class, "inspect", rb_objc_debug_description, 0);
    }
    else if (objc_class == [NSString class]) {
      rb_define_method(rb_class, "to_s", rb_objc_get_ruby_object, 0);
    }
    else if (objc_class == [NSArray class]) {
      rb_define_method(rb_class, "to_a", rb_objc_get_ruby_object, 0);
    }
    else if (objc_class == [NSDictionary class]) {
      rb_define_method(rb_class, "to_h", rb_objc_get_ruby_object, 0);
    }
    else if (objc_class == [NSDate class]) {
      rb_define_method(rb_class, "to_time", rb_objc_get_ruby_object, 0);
    }
    else if (objc_class == [NSNumber class]) {
      rb_define_method(rb_class, "to_i", rb_objc_get_ruby_int, 0);
      rb_define_method(rb_class, "to_f", rb_objc_get_ruby_float, 0);
    }
    
    // Remember that this class is now defined in Ruby
    NSMapInsertKnownAbsent(knownClasses, (void*)objc_class, (void*)rb_class);
    
    NSDebugLog(@"VALUE for new Ruby Class %s = %p", cname, (void*)rb_class);

    return rb_class;
  }
}

VALUE
rb_objc_register_class_from_ruby(VALUE rb_self, VALUE rb_class)
{
  @autoreleasepool {
    long i;
    long count;
    VALUE listOption;
    int nbArgs;
    VALUE rb_mth_ary;
    VALUE rb_super_class;
    Class superClass;
    Class class;
    const char *rb_mth_name;
    SEL objcMthSEL;
    const char *objcTypes;
    const char *rb_class_name;
    void *mthIMP;
    unsigned long hash;

    Check_Type(rb_class, T_CLASS);
  
    rb_class_name = rb_class2name(rb_class);

    NSDebugLog (@"Registering Ruby class %s with the objective-C runtime", 
                rb_class_name);

    // If this class has already been registered with ObjC then
    // do nothing
    if ( (class = objc_lookUpClass(rb_class_name)) ) {
      NSDebugLog(@"Class already registered with ObjC: %s", rb_class_name);
      return Qfalse;
    }
  
    // Create the Objective-C proxy class. 
    rb_super_class = rb_class_superclass(rb_class);
    if (rb_super_class == rb_cObject || rb_super_class == rb_cBasicObject) {
      superClass = [NSObject class];
    }
    else {
      // TODO: possible this class isn't registered yet
      // Could be something that hasn't been imported yet
      // Or could be something that hasn't been registered yet
      // rb_super_class = rb_objc_register_class_from_objc(objc_super_class);
    
      superClass = (Class) NUM2LL(rb_iv_get(rb_super_class, "@objc_class"));
    }
  
    class = objc_allocateClassPair (superClass, rb_class_name, 0);
    if (class == nil) {
      rb_raise(rb_eTypeError, "could not allocate class pair with ObjC: %s", rb_class_name);
    }

    // Get instance method list. Pass no argument to function to
    // eliminate ancestor's method from the list.
    listOption = Qfalse;
    rb_mth_ary = rb_class_instance_methods(1,&listOption,rb_class);
    // number of instance methods in this class
    count = rb_array_len(rb_mth_ary);
    NSDebugLog(@"Ruby class %s has %ld instance methods", rb_class_name, count);
  
    for (i=0;i<count;i++) {
      ID entry = rb_sym2id(rb_ary_entry(rb_mth_ary, i));
      nbArgs = rb_mod_method_arity(rb_class, entry);

      if (nbArgs < 0) continue;

      rb_mth_name = rb_id2name(entry);
      objcMthSEL = rb_objc_method_to_sel(rb_mth_name, nbArgs);

      objcTypes = rb_objc_types_for_selector(objcMthSEL, nbArgs);

      hash = rb_objc_hash(objcTypes);
      mthIMP = NSMapGet(knownImplementations, (void*)hash);

      if (mthIMP != NULL) {
        class_addMethod(class, objcMthSEL, mthIMP, objcTypes);
        continue;
      }

      ffi_closure *closure = NULL;
      ffi_cif *cif;

      cif = malloc(sizeof(ffi_cif));

      if (rb_objc_build_closure_cif(cif, objcTypes) == FFI_OK) {
        closure = ffi_closure_alloc(sizeof(ffi_closure), &mthIMP);
        if (ffi_prep_closure_loc(closure, cif, rb_objc_proxy_handler, (void*)objcTypes, mthIMP) == FFI_OK) {
          NSMapInsertKnownAbsent(knownImplementations, (void*)hash, (void*)mthIMP);
          class_addMethod(class, objcMthSEL, mthIMP, objcTypes);
        }
      }

      NSDebugLog(@"Ruby method %s has %d arguments with signature %s", rb_mth_name, nbArgs, objcTypes);
    }
  
    objc_registerClassPair(class);

    //Store the ObjcC Class id in the @@objc_class Ruby Class Variable
    rb_iv_set(rb_class, "@objc_class", LL2NUM((long long)class));

    // Remember that this class is defined in Ruby
    NSMapInsertKnownAbsent(knownClasses, (void*)class, (void*)rb_class);

    // Redefine the new method to point to our special rb_objc_new function
    rb_undef_alloc_func(rb_class);
    rb_undef_method(CLASS_OF(rb_class),"new");
    rb_define_singleton_method(rb_class, "new", rb_objc_new, -1);

    return Qtrue;
  
  }
}

VALUE
rb_objc_require_framework_from_ruby(VALUE rb_self, VALUE rb_name)
{
  @autoreleasepool {
    char *cname = rb_string_value_cstr(&rb_name);
    NSString *path = [NSString stringWithFormat:@"/System/Library/Frameworks/%s.framework/", cname];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSBundle *bundle = [NSBundle bundleWithURL:url];

    if (bundle == nil) {
      rb_raise(rb_eLoadError, "cannot load such framework -- %s", cname);
    }
  
    if (NSHashGet(knownFrameworks, (void*)bundle.bundleIdentifier.hash)) {
      return Qfalse;
    }

    path = [NSString stringWithFormat:@"BridgeSupport/%s.dylib", cname];
    url = [[bundle resourceURL] URLByAppendingPathComponent:path];

    dlopen([url fileSystemRepresentation], RTLD_LAZY);

#ifdef __aarch64__
    path = [NSString stringWithFormat:@"BridgeSupport/%s.arm64e.bridgesupport", cname];
#else
    path = [NSString stringWithFormat:@"BridgeSupport/%s.bridgesupport", cname];
#endif
    url = [[bundle resourceURL] URLByAppendingPathComponent:path];

    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    RIGSBridgeSupportParser *delegate = [[RIGSBridgeSupportParser alloc] init];

    parser.delegate = delegate;

    BOOL parsed = [parser parse];

    [parser release];
    [delegate release];

    if (parsed) {
      NSHashInsertKnownAbsent(knownFrameworks, (void*)bundle.bundleIdentifier.hash);
      return Qtrue;
    }
    rb_raise(rb_eLoadError, "cannot parse such framework -- %s", cname);
  }
}

void
rb_objc_ptr_free(struct rb_objc_ptr *dp)
{
  NSDebugLog(@"Call to ObjRuby::Pointer free on %p", dp);
  
  @autoreleasepool {
    id obj;
    size_t offset;

    if (dp != NULL) {
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
    
    obj = Data_Wrap_Struct(rb_class, 0, rb_objc_ptr_free, dp);

    return obj;
  }
}

VALUE
rb_objc_ptr_get(VALUE rcv, VALUE index)
{
  @autoreleasepool {
    NSUInteger offset;
    struct rb_objc_ptr *dp;
    VALUE val;
    BOOL converted;

    Check_Type(index, T_FIXNUM);
  
    dp = (struct rb_objc_ptr*)DATA_PTR(rcv);

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
rb_objc_ptr_inspect(VALUE rcv)
{
  @autoreleasepool {
    char s[512];
    VALUE rb_class;
    struct rb_objc_ptr *dp;

    rb_class = rb_mod_name(CLASS_OF(rcv));
    dp = (struct rb_objc_ptr*)DATA_PTR(rcv);
  
    snprintf(s, sizeof(s), "#<%s:%p cptr=%p allocated_size=%ld encoding=%s>",
             rb_string_value_cstr(&rb_class),
             (void*)rcv,
             dp->cptr,
             dp->allocated_size,
             dp->encoding ?: "(NULL)");
  
    return rb_str_new2(s);  
  }
}

void __attribute__((noreturn))
  rb_objc_raise_exception(NSException *exception)
{
  const char *class_name;
  const char *message;
  VALUE rb_exception;

  class_name = [[[exception name] stringByReplacingOccurrencesOfString:@"Exception"
                                                            withString:@"Error"] UTF8String];
  message = [[exception reason] UTF8String];
    
  rb_exception = rb_define_class_under(rb_mRigs, class_name, rb_eRuntimeError);
  rb_raise(rb_exception, "%s", message);
}



/* Called when require 'obj_ext' is executed in Ruby */
void
Init_obj_ext()
{
  // Initialize hash tables of known Objective-C bridge data
  knownClasses = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
  knownObjects = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
  knownStructs = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
  knownFunctions = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
  knownBlocks = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
  knownProtocols = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
  knownImplementations = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
  knownFormatStrings = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSIntegerMapValueCallBacks, 0);
  knownFrameworks = NSCreateHashTable(NSIntegerHashCallBacks, 0);

  // reference protocols so objc_getProtocol sees them
  @protocol(NSApplicationDelegate);
  @protocol(NSConnectionDelegate);
  @protocol(NSURLDownloadDelegate);
  @protocol(NSUserNotificationCenterDelegate);
  @protocol(NSAlertDelegate);
  @protocol(NSBrowserDelegate);
  @protocol(NSDrawerDelegate);
  @protocol(NSOutlineViewDataSource);
  @protocol(NSOutlineViewDelegate);
  @protocol(NSPathControlDelegate);
  @protocol(NSServicesMenuRequestor);
  @protocol(NSTextContentManagerDelegate);
  @protocol(NSTextFinderClient);
  @protocol(NSTextLayoutManagerDelegate);
  @protocol(NSTokenFieldCellDelegate);
  @protocol(NSTokenFieldDelegate);

  // Ruby class methods under the ObjC Ruby module
  // - ObjRuby.require_framework("Foundation"): registers ObjC framework with Ruby
  // - ObjRuby.register_class(AppDelegate): registers Ruby class with ObjC

  rb_mRigs = rb_define_module("ObjRuby");
  rb_define_module_function(rb_mRigs, "require_framework", rb_objc_require_framework_from_ruby, 1);
  rb_define_module_function(rb_mRigs, "register_class", rb_objc_register_class_from_ruby, 1);

  // Ruby class for holding a C-style pointer
  //  - ObjRuby::Pointer.new(:object): pointer to an "id" ObjC object like NSError
  rb_cRigsPtr = rb_define_class_under(rb_mRigs, "Pointer", rb_cObject);
  rb_undef_alloc_func(rb_cRigsPtr);
  rb_undef_method(CLASS_OF(rb_cRigsPtr), "new");
  rb_define_singleton_method(rb_cRigsPtr, "new", rb_objc_ptr_new, -1);  
  rb_define_method(rb_cRigsPtr, "inspect", rb_objc_ptr_inspect, 0);
  rb_define_method(rb_cRigsPtr, "[]", rb_objc_ptr_get, 1);

  // Catch all Objective-C raised exceptions and direct them to Ruby
  NSSetUncaughtExceptionHandler(rb_objc_raise_exception);
}
