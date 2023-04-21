# NSWindow.rb - Add a couple of things to the Objective C NSWindow class
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

NSWindow = ObjRuby.class("NSWindow")

# enum Window levels
NSDesktopWindowLevel 	 = -1000	# GNUstep addition
NSNormalWindowLevel  	= 0
NSFloatingWindowLevel  	= 3
NSSubmenuWindowLevel  	= 3
NSTornOffMenuWindowLevel = 3
NSMainMenuWindowLevel  	= 20
NSDockWindowLevel  	= 21	# Deprecated - use NSStatusWindowLevel
NSStatusWindowLevel  	= 21
NSModalPanelWindowLevel = 100
NSPopUpMenuWindowLevel  = 101
NSScreenSaverWindowLevel = 1000


# enum Window properties
NSBorderlessWindowMask  = 0
NSTitledWindowMask  	= 1
NSClosableWindowMask  	= 2
NSMiniaturizableWindowMask = 4
NSResizableWindowMask  	= 8

NSWindowStyleMaskBorderless = 0
NSWindowStyleMaskTitled = 1
NSWindowStyleMaskClosable = 2
NSWindowStyleMaskMiniaturizable = 4
NSWindowStyleMaskResizable = 8

#enum NSSelectionDirection 
NSDirectSelection   = 0
NSSelectingNext     = 1
NSSelectingPrevious = 2
