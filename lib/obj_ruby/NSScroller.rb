# NSScroller.rb - Add a couple of things to the Objective C NSScroller class
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

NSScroller = ObjRuby.class("NSScroller")

# NSScrollArrowPosition 
NSScrollerArrowsMaxEnd = 0
NSScrollerArrowsMinEnd = 1
NSScrollerArrowsNone = 2


# NSScrollerPart
NSScrollerNoPart = 0
NSScrollerDecrementPage = 1
NSScrollerKnob = 2
NSScrollerIncrementPage = 3
NSScrollerDecrementLine = 4
NSScrollerIncrementLine = 5
NSScrollerKnobSlot = 6

# NSScrollerUsablePart 
NSNoScrollerParts = 0
NSOnlyScrollerArrows = 1
NSAllScrollerParts = 2


# NSScrollerArrow
NSScrollerIncrementArrow = 0
NSScrollerDecrementArrow = 1
