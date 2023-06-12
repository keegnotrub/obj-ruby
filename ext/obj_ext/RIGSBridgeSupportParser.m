/* RIGSBridgeSupportParser.m - Delegate to parse BridgeSupport files

   $Id$

   Copyright (C) 2023 thoughtbot, Inc.
   
   Written by:  Ryan Krug <ryan.krug@thoughtbot.com>
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

#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSCharacterSet.h>
#import "RIGSBridgeSupportParser.h"
#include "RIGSCore.h"

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
  else if ([elementName isEqualToString:@"method"]) {
    [self parseMethodWithSelector:[attributeDict objectForKey:@"selector"]
                         variadic:[attributeDict objectForKey:@"variadic"]];
  }
  else if ([elementName isEqualToString:@"function"]) {
    [self parseFunctionWithName:[attributeDict objectForKey:@"name"]];
  }
  else if ([elementName isEqualToString:@"retval"]) {
    [self parseArgWithIndex:-1
                       type:[attributeDict objectForKey:@"type64"]
                     printf:nil];
  }
  else if ([elementName isEqualToString:@"arg"]) {
    if (_methodName) {
      [self parseArgWithIndex:[[attributeDict objectForKey:@"index"] intValue]
                         type:[attributeDict objectForKey:@"type64"]
                       printf:[attributeDict objectForKey:@"printf_format"]];
    }
    else if (_functionName) {
      [self parseArgWithIndex:_argIndex++
                         type:[attributeDict objectForKey:@"type64"]
                       printf:[attributeDict objectForKey:@"printf_format"]];
    }
  }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
  if (_methodName && [elementName isEqualToString:@"method"]) {
    [self finalizeMethod];
  }
  else if (_functionName && [elementName isEqualToString:@"function"]) {
    [self finalizeFunction];
  }
}

- (void)finalizeFunction
{
  rb_objc_register_function_from_objc([_functionName cString], [_objcTypes cString], _formatStringIndex);

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

- (void)parseFunctionWithName:(NSString*)name
{
  _functionName = [name retain];
  _objcTypes = [[NSMutableString string] retain];
  _formatStringIndex = -1;
  _argIndex = 0;
}

- (void)parseMethodWithSelector:(NSString*)selector variadic:(NSString*)variadic
{
  if ([variadic isEqualToString:@"true"]) {
    _methodName = [selector retain];
  }
}

- (void)parseArgWithIndex:(NSInteger)index type:(NSString*)type printf:(NSString*)printf
{
  if (_methodName) {
    if ([printf isEqualToString:@"true"]) {
      rb_objc_register_method_arg_from_objc([_methodName cString], index, YES);
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
  NSScanner *scanner = [NSScanner scannerWithString:type];
  NSString *structKey;
  NSString *arg;

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

    args[argIndex++] = [arg cString];
  }

  rb_objc_register_struct_from_objc([structKey cString], [name cString], args, argCount);

  free(args);
}

- (void)parseConstantWithName:(NSString*)name type:(NSString*)type
{
  rb_objc_register_constant_from_objc([name cString], [type cString]);
}

- (void)parseEnumWithName:(NSString*)name value:(NSString*)value
{
  if ([name isEqualToString:@"NSNotFound"]) {
    rb_objc_register_integer_from_objc([name cString], NSIntegerMax);
    return;
  }
    
  NSScanner *scanner = [NSScanner scannerWithString:value];
  long long integerResult;
  double floatResult;

  if ([scanner scanLongLong:&integerResult] && scanner.atEnd) {
    rb_objc_register_integer_from_objc([name cString], integerResult);
  }
  else if ([scanner scanDouble:&floatResult] && scanner.atEnd) {
    rb_objc_register_float_from_objc([name cString], floatResult);
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
