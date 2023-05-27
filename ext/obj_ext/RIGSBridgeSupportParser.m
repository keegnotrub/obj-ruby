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
  else if ([elementName isEqualToString:@"arg"]) {
    [self parseArgWithIndex:[attributeDict objectForKey:@"index"]
                     printf:[attributeDict objectForKey:@"printf_format"]];
  }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName {
  if (_variadicMethod && [elementName isEqualToString:@"method"]) {
    [_variadicMethod release];
    _variadicMethod = nil;
  }
}

- (void)parseMethodWithSelector:(NSString*)selector variadic:(NSString*)variadic
{
  if ([variadic isEqualToString:@"true"]) {
    _variadicMethod = [selector retain];
  }
}

- (void)parseArgWithIndex:(NSString*)index printf:(NSString*)printf
{
  if (_variadicMethod && [printf isEqualToString:@"true"]) {
    rb_objc_register_method_arg_from_objc([_variadicMethod cString], [index intValue], true);
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
