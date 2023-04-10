# Foundation.rb - Load all Foundation  classes at once
#
#  $Id$
#
#    Copyright (C) 2001 Free Software Foundation, Inc.
#   
#    Written by:  Laurent Julliard <laurent@julliard-online.org>
#    Date: September 2001
#  
#    This file is part of the GNUstep Ruby Interface Library.
#
#    This library is free software; you can redistribute it and/or
#    modify it under the terms of the GNU Library General Public
#    License as published by the Free Software Foundation; either
#    version 2 of the License, or (at your option) any later version.
#   
#    This library is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Library General Public License for more details.
#   
#    You should have received a copy of the GNU Library General Public
#    License along with this library; if not, write to the Free
#    Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
#

# Just in case it was forgotten by the user....
require 'obj_ruby'

FoundationClasses = [ 
"NSDebug",
"NSObject",
"NSArchiver",
"NSArray",
"NSMutableArray",
"NSAttributedString",
"NSMutableAttributedString",
"NSAutoreleasePool",
"NSBundle",
"NSByteOrder",
"NSCalendarDate",
"NSCharacterSet",
"NSMutableCharacterSet",
"NSClassDescription",
"NSCoder",
"NSConnection",
"NSDate",
"NSDateFormatter",
"NSData",
"NSMutableData",
"NSDictionary",
"NSMutableDictionary",
"NSDecimalNumber",
"NSDistantObject",
"NSDistributedLock",
"NSDistributedNotificationCenter",
"NSEnumerator",
"NSException",
"NSFileHandle",
"NSFileManager",
"NSFormatter",
"NSHashTable",
"NSGeometry",
"NSHost",
"NSInvocation",
"NSKeyValueCoding",
"NSLock",
"NSMapTable",
"NSMethodSignature",
"NSNotification",
"NSNotificationQueue",
"NSNull",
"NSPathUtilities",
"NSPortCoder",
"NSPortMessage",
"NSPortNameServer",
"NSProcessInfo",
"NSProtocolChecker",
"NSProxy",
"NSRange",
"NSRunLoop",
"NSScanner",
"NSSerialization",
"NSSet",
"NSMutableSet",
"NSString",
"NSMutableString",
"NSTask",
"NSThread",
"NSTimeZone",
"NSTimer",
"NSURL",
"NSURLHandle",
"NSUndoManager",
"NSUserDefaults",
"NSValue",
"NSZone"]

FoundationClasses.each { |aClass|  ObjRuby.import(aClass) }

