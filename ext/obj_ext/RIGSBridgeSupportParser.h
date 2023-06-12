/* RIGSBridgeSupportParser.h - Delegate to parse BridgeSupport files

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

#ifndef __RIGSBridgeSupportParser_h_GNUSTEP_RUBY_INCLUDE
#define __RIGSBridgeSupportParser_h_GNUSTEP_RUBY_INCLUDE

#import <Foundation/NSObject.h>
#import <Foundation/NSXMLParser.h>

@interface RIGSBridgeSupportParser : NSObject<NSXMLParserDelegate>
{
  NSString *_methodName;
  NSString *_functionName;
  NSMutableString *_objcTypes;
  NSInteger _formatStringIndex;
  NSInteger _argIndex;
}

@end

#endif
