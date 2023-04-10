# NSGraphicsContext.rb - Add a couple of things to the Objective C NSGraphicsContext class
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

NSGraphicsContext = ObjRuby.class("NSGraphicsContext")

# NSBackingStoreType
NSBackingStoreRetained = 0
NSBackingStoreNonretained = 1
NSBackingStoreBuffered = 2

# NSCompositingOperation

NSCompositeClear = 0
NSCompositeCopy = 1
NSCompositeSourceOver = 2
NSCompositeSourceIn = 3
NSCompositeSourceOut = 4
NSCompositeSourceAtop = 5
NSCompositeDestinationOver = 6
NSCompositeDestinationIn = 7
NSCompositeDestinationOut = 8
NSCompositeDestinationAtop = 9
NSCompositeXOR = 10
NSCompositePlusDarker = 11
NSCompositeHighlight = 12
NSCompositePlusLighter = 13

# NSWindowOrderingMode

NSWindowAbove = 0
NSWindowBelow = 1
NSWindowOut = 2

# GSWindowInputState - GNUstep only 

GSTitleBarKey = 0
GSTitleBarNormal = 1
GSTitleBarMain = 2
