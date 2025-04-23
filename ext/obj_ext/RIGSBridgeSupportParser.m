/* RIGSBridgeSupportParser.m - Delegate to parse BridgeSupport files

   Written by: Ryan Krug <ryank@kit.com>
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
    [self parseMethodWithName:[attributeDict objectForKey:@"selector"]];
  }
  else if ([elementName isEqualToString:@"function"]) {
    [self parseFunctionWithName:[attributeDict objectForKey:@"name"]];
  }
  else if ([elementName isEqualToString:@"retval"]) {
    [self parseArgWithIndex:-1
                       type:[attributeDict objectForKey:@"type64"]
                     printf:nil
                      block:nil];
  }
  else if ([elementName isEqualToString:@"arg"]) {
    if (_methodName) {
      [self parseArgWithIndex:[attributeDict objectForKey:@"index"] ? [[attributeDict objectForKey:@"index"] intValue] : _argIndex++
                         type:[attributeDict objectForKey:@"type64"]
                       printf:[attributeDict objectForKey:@"printf_format"]
                        block:[attributeDict objectForKey:@"function_pointer"]];
    }
    else if (_functionName) {
      [self parseArgWithIndex:_argIndex++
                         type:[attributeDict objectForKey:@"type64"]
                       printf:[attributeDict objectForKey:@"printf_format"]
                        block:nil];
    }
  }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
  if ([elementName isEqualToString:@"method"]) {
    [self finalizeMethod];
  }
  else if ([elementName isEqualToString:@"function"]) {
    [self finalizeFunction];
  }
  else if ([elementName isEqualToString:@"arg"] || [elementName isEqualToString:@"retval"]) {
    [self finalizeArg];
  }
}

- (void)finalizeArg
{
  _argDepth--;

  if (_argDepth > 0) return;
  
  if (_blockIndex != -1) {
    if (_methodName) {
      rb_objc_register_block_from_objc([_methodName UTF8String], _blockIndex, [_objcTypes UTF8String]);
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

- (void)finalizeFunction
{
  rb_objc_register_function_from_objc([_functionName UTF8String], [_objcTypes UTF8String]);
  
  [_objcTypes release];
  _objcTypes = nil;
  [_functionName release];
  _functionName = nil;
}

- (void)finalizeMethod
{
  [_methodName release];
  _methodName = nil;
}

- (void)parseProtocolWithName:(NSString*)name
{
  rb_objc_register_protocol_from_objc([name UTF8String]);
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

- (void)parseMethodWithName:(NSString*)selector
{
  _methodName = [selector retain];
  _formatStringIndex = -1;
  _blockIndex = -1;
  _argIndex = 0;
  _argDepth = 0;
}

- (void)parseArgWithIndex:(NSInteger)index type:(NSString*)type printf:(NSString*)printf block:(NSString*)block
{
  _argDepth++;
  
  if (_methodName) {
    if ([printf isEqualToString:@"true"]) {
      _formatStringIndex = index;
    }
    if ([block isEqualToString:@"true"] && [type isEqualToString:@"@?"]) {
      _blockIndex = index;
      _objcTypes = [[NSMutableString string] retain];
    }
    if (_objcTypes) {
      if (index == -1) {
        [_objcTypes insertString:type atIndex:0];
      }
      else {
        [_objcTypes appendString:type];
      }
    }
  }
  else if (_functionName) {
    if ([printf isEqualToString:@"true"]) {
      _formatStringIndex = index;
    }
    if (index == -1) {
      [_objcTypes insertString:type atIndex:0];
    }
    else {
      [_objcTypes appendString:type];
    }
  }
}

- (void)parseStructWithName:(NSString*)name type:(NSString*)type
{
  NSScanner *scanner;
  NSString *structKey;
  NSString *arg;

  // skip: "struct (unnamed at ...)"
  if ([name containsString:@" "]) return;
  
  scanner = [NSScanner scannerWithString:type];

  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{"] intoString:NULL];
  [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="] intoString:&structKey];
  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="] intoString:NULL];
  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"}"] intoString:NULL];

  NSUInteger argCount = [self parseStructArgCountWithType:type];

  const char **args = malloc(argCount * sizeof(const char *));
  int argIndex = 0;
  while (!scanner.atEnd) {
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:NULL];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:&arg];

    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:NULL];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"}"] intoString:NULL];
    [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"}"] intoString:NULL];

    args[argIndex++] = [arg UTF8String];
  }

  rb_objc_register_struct_from_objc([structKey UTF8String], [name UTF8String], args, argCount);

  free(args);
}

- (void)parseConstantWithName:(NSString*)name type:(NSString*)type
{
  rb_objc_register_constant_from_objc([name UTF8String], [type UTF8String]);
}

- (void)parseEnumWithName:(NSString*)name value:(NSString*)value
{
  if ([name isEqualToString:@"NSNotFound"]) {
    rb_objc_register_integer_from_objc([name UTF8String], NSIntegerMax);
    return;
  }
    
  NSScanner *scanner = [NSScanner scannerWithString:value];
  long long integerResult;
  double floatResult;

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

@end
