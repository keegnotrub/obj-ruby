# NSBezierPath.rb - Add a couple of things to the Objective C NSBezierPath class
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

NSBezierPath = ObjRuby.class("NSBezierPath")

# All from NSBezierPath.h

# NSLineCapStyle
NSButtLineCapStyle   = 0
NSRoundLineCapStyle  = 1
NSSquareLineCapStyle = 2

# NSLineJoinStyle
NSMiterLineJoinStyle = 0
NSRoundLineJoinStyle = 1
NSBevelLineJoinStyle = 2

# NSWindingRule
NSNonZeroWindingRule = 0
NSEvenOddWindingRule = 1


# NSBezierPathElement
NSMoveToBezierPathElement    = 0
NSLineToBezierPathElement    = 1
NSCurveToBezierPathElement   = 2
NSClosePathBezierPathElement = 3

