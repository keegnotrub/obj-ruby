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
#import "RIGSBridgeSupportParser.h"
#include "RIGSCore.h"

@implementation RIGSBridgeSupportParser

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary*)attributeDict {
  if ([elementName isEqualToString:@"enum"]) {
    NSString *name = [attributeDict objectForKey:@"name"];

    if ([name isEqualToString:@"NSNotFound"]) {
      // Bug in BridgeSupport - call with NSIntegerMax
      return;
    }
    
    NSString *value = [attributeDict objectForKey:@"value64"];
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
  else if ([elementName isEqualToString:@"class"]) {
    NSString *name = [attributeDict objectForKey:@"name"];

    Class objc_class = NSClassFromString(name);

    if (objc_class) {
      rb_objc_register_class_from_objc(objc_class);
    }
  }
}

@end
