/* RIGSBridgeSupportParser.m - Delegate to parse BridgeSupport files

   Written by: Ryan Krug <keegnotrub@icloud.com>
   Date: May 2023

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

#import "RIGSBridgeSupportParser.h"
#import "RIGSCore.h"

@implementation RIGSBridgeSupportParser

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary*)attributeDict {
  if ([elementName isEqualToString:@"struct"]) {
    [self parseStructWithName:[attributeDict objectForKey:@"name"]
                         type:[attributeDict objectForKey:@"type64"]];
  }
  else if ([elementName isEqualToString:@"constant"]) {
    [self parseConstantWithName:[attributeDict objectForKey:@"name"]
                           type:[attributeDict objectForKey:@"type64"]];
  }
  else if ([elementName isEqualToString:@"enum"]) {
    [self parseEnumWithName:[attributeDict objectForKey:@"name"]
                      value:[attributeDict objectForKey:@"value64"]];
  }
  else if ([elementName isEqualToString:@"class"]) {
    [self parseClassWithName:[attributeDict objectForKey:@"name"]];
  }
  else if ([elementName isEqualToString:@"informal_protocol"]) {
    [self parseProtocolWithName:[attributeDict objectForKey:@"name"]];
  }
  else if ([elementName isEqualToString:@"method"]) {
    [self parseMethodWithName:[attributeDict objectForKey:@"selector"]
                         type:[attributeDict objectForKey:@"type64"]];
  }
  else if ([elementName isEqualToString:@"function"]) {
    [self parseFunctionWithName:[attributeDict objectForKey:@"name"]];
  }
  else if ([elementName isEqualToString:@"retval"]) {
    [self parseArgWithType:[attributeDict objectForKey:@"type64"]
                     index:@"-1"
                    printf:nil
                     block:nil];
  }
  else if ([elementName isEqualToString:@"arg"]) {
    [self parseArgWithType:[attributeDict objectForKey:@"type64"]
                     index:[attributeDict objectForKey:@"index"]
                    printf:[attributeDict objectForKey:@"printf_format"]
                     block:[attributeDict objectForKey:@"function_pointer"]];
  }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
  if ([elementName isEqualToString:@"informal_protocol"]) {
    [self finalizeProtocol];
  }
  else if ([elementName isEqualToString:@"method"]) {
    [self finalizeMethod];
  }
  else if ([elementName isEqualToString:@"function"]) {
    [self finalizeFunction];
  }
  else if ([elementName isEqualToString:@"arg"] || [elementName isEqualToString:@"retval"]) {
    [self finalizeArg];
  }
}

- (void)parseFunctionWithName:(NSString*)name
{
  _functionName = [name retain];
  _objcTypes = [[NSMutableString string] retain];
  _formatStringIndex = -1;
  _blockIndex = -1;
  _argIndex = 0;
  _argDepth = 0;
}

- (void)parseMethodWithName:(NSString*)selector type:(NSString*)type
{
  NSMethodSignature *signature;
  NSUInteger nbArgs;
  NSUInteger i;
  
  _methodName = [selector retain];
  if (type) {
    if ([type isEqualToString:@"TB,R"] || [type isEqualToString:@"TB,?,R"]) {
      _objcTypes = [[NSMutableString stringWithString:@"B@:"] retain];
    }
    else {
      signature = [NSMethodSignature signatureWithObjCTypes:[type UTF8String]];
      nbArgs = [signature numberOfArguments];
      _objcTypes = [[NSMutableString stringWithCapacity:128] retain];
      [_objcTypes appendFormat: @"%s", [signature methodReturnType]];
      for (i=0;i<nbArgs;i++) {
        [_objcTypes appendFormat: @"%s", [signature getArgumentTypeAtIndex:i]];
      }
    }
  }
  _formatStringIndex = -1;
  _blockIndex = -1;
  _argIndex = 0;
  _argDepth = 0;
}

- (void)parseProtocolWithName:(NSString*)name
{
  _protocolName = [name retain];
  _formatStringIndex = -1;
  _blockIndex = -1;
  _argIndex = 0;
  _argDepth = 0;
}

- (void)parseArgWithType:(NSString*)type index:(NSString*)index printf:(NSString*)printf block:(NSString*)block
{
  _argDepth++;
  
  if (_methodName) {
    if (_argDepth == 1) {
      if ([printf isEqualToString:@"true"]) {
        _formatStringIndex = [index integerValue];
      }
      if ([block isEqualToString:@"true"] && [type isEqualToString:@"@?"]) {
        _blockIndex = [index integerValue];
        _objcTypes = [[type mutableCopy] retain];
      }
      if (type) {
        rb_objc_register_type_arg_from_objc([_methodName UTF8String], [index intValue], [type UTF8String]);
      }
    }
    else {
      if (_objcTypes) {
        if ([index isEqualToString:@"-1"]) {
          [_objcTypes insertString:type atIndex:0];
        }
        else {
          [_objcTypes appendString:type];
        }
      }
    }
  }
  else if (_functionName) {
    if (_argDepth == 1) {
      if ([printf isEqualToString:@"true"]) {
        _formatStringIndex = _argIndex;
      }
      if ([index isEqualToString:@"-1"]) {
        [_objcTypes insertString:type atIndex:0];
      }
      else {
        [_objcTypes appendString:type];
      }
      _argIndex++;
    }
  }
}

- (void)parseStructWithName:(NSString*)name type:(NSString*)type
{
  NSScanner *scanner;
  NSString *structKey;
  NSString *argName;
  NSString *argType;
  NSUInteger argCount;
  const char **args;
  int argIndex;
  BOOL supported;

  // skip: "struct (unnamed at ...)"
  if ([name containsString:@" "]) return;

  scanner = [NSScanner scannerWithString:type];
  supported = YES;

  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{"] intoString:NULL];
  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"_"] intoString:NULL];
  [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="] intoString:&structKey];
  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="] intoString:NULL];
  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"}"] intoString:NULL];

  argCount = [self parseStructArgCountWithType:type];

  args = malloc(argCount * sizeof(const char *));
  argIndex = 0;
  while (!scanner.atEnd) {
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:NULL];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:&argName];

    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:NULL];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:&argType];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"}"] intoString:NULL];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"}"] intoString:NULL];

    args[argIndex++] = [argName UTF8String];

    // We don't support unknown or void pointers at this time
    if ([argType isEqualToString:@"^?"] || [argType isEqualToString:@"^v"]) {
      supported = NO;
    }
  }

  if (supported) {
    rb_objc_register_struct_from_objc([structKey UTF8String], [name UTF8String], args, argCount);
  }

  free(args);
}

- (void)parseConstantWithName:(NSString*)name type:(NSString*)type
{
  rb_objc_register_constant_from_objc([name UTF8String], [type UTF8String]);
}

- (void)parseEnumWithName:(NSString*)name value:(NSString*)value
{
  NSScanner *scanner;
  long long integerResult;
  double floatResult;

  if ([name isEqualToString:@"NSNotFound"]) {
    rb_objc_register_integer_from_objc([name UTF8String], NSIntegerMax);
    return;
  }

  scanner = [NSScanner scannerWithString:value];

  if ([scanner scanLongLong:&integerResult] && scanner.atEnd) {
    rb_objc_register_integer_from_objc([name UTF8String], integerResult);
  }
  else if ([scanner scanDouble:&floatResult] && scanner.atEnd) {
    rb_objc_register_float_from_objc([name UTF8String], floatResult);
  }
}

- (void)parseClassWithName:(NSString*)name
{
  Class objc_class = NSClassFromString(name);

  if (objc_class) {
    rb_objc_register_class_from_objc(objc_class);
  }
}

- (NSUInteger)parseStructArgCountWithType:(NSString*)type
{
  NSMutableString *mType = [NSMutableString stringWithString:type];
  NSUInteger quoteCount = [mType replaceOccurrencesOfString:@"\""
                                                 withString:@""
                                                    options:NSLiteralSearch
                                                      range:NSMakeRange(0, [type length])];

  return quoteCount / 2;
}

- (void)finalizeProtocol
{
  [_protocolName release];
  _protocolName = nil;
}

- (void)finalizeMethod
{
  if (_protocolName) {
    rb_objc_register_protocol_from_objc([_methodName UTF8String], [_objcTypes UTF8String]);
  }

  [_objcTypes release];
  _objcTypes = nil;
  [_methodName release];
  _methodName = nil;
}

- (void)finalizeFunction
{
  rb_objc_register_function_from_objc([_functionName UTF8String], [_objcTypes UTF8String]);
  
  [_objcTypes release];
  _objcTypes = nil;
  [_functionName release];
  _functionName = nil;
}

- (void)finalizeArg
{
  _argDepth--;

  if (_argDepth > 0) return;
  
  if (_blockIndex != -1) {
    if (_methodName) {
      rb_objc_register_block_arg_from_objc([_methodName UTF8String], _blockIndex, [_objcTypes UTF8String]);
    }

    _blockIndex = -1;
    [_objcTypes release];
    _objcTypes = nil;
  }

  if (_formatStringIndex != -1) {
    if (_methodName) {
      rb_objc_register_format_string_from_objc([_methodName UTF8String], _formatStringIndex);
    }
    else if (_functionName) {
      rb_objc_register_format_string_from_objc([_functionName UTF8String], _formatStringIndex);
    }
    _formatStringIndex = -1;
  }
}

@end
