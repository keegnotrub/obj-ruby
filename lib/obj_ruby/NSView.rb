# NSView.rb - Add a couple of things to the Objective C NSView class
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

NSView = ObjRuby.class("NSView")

# enum NSBorderType {
NSNoBorder 	= 0
NSLineBorder 	= 1
NSBezelBorder 	= 2
NSGrooveBorder 	= 3

# enum 
NSViewNotSizable	= 0	# view does not resize with its superview
NSViewMinXMargin	= 1	# left margin between views can stretch
NSViewWidthSizable	= 2	# view's width can stretch
NSViewMaxXMargin	= 4	# right margin between views can stretch
NSViewMinYMargin	= 8	# bottom margin between views can stretch
NSViewHeightSizable	= 16	# view's height can stretch
NSViewMaxYMargin	= 32 	# top margin between views can stretch
