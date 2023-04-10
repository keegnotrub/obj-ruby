# NSEvent.rb - Add a couple of things to the Objective C NSEvent class
#
#  $Id$
#
#    Copyright (C) 2001 Free Software Foundation, Inc.
#   
#    Written by:  Laurent Julliard <laurent@julliard-online.org>
#    Date: July 2001
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

NSEvent = ObjRuby.class("NSEvent")

# NSEventType
NSLeftMouseDown = 0
NSLeftMouseUp = 1
NSMiddleMouseDown = 	2	# GNUstep extension
NSMiddleMouseUp = 3		# GNUstep extension
NSRightMouseDown = 4
NSRightMouseUp = 5
NSMouseMoved = 6
NSLeftMouseDragged = 7
NSMiddleMouseDragged = 8	# GNUstep extension
NSRightMouseDragged = 9
NSMouseEntered = 10
NSMouseExited = 11
NSKeyDown = 12
NSKeyUp = 13
NSFlagsChanged = 14
NSAppKitDefined = 15
NSSystemDefined = 16
NSApplicationDefined = 17
NSPeriodic = 18
NSCursorUpdate = 19
NSScrollWheel = 20
