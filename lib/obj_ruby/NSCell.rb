# NSCell.rb - Add a couple of things to the Objective C NSCell class
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

NSCell = ObjRuby.class("NSCell")

# NSCellType 
NSNullCellType = 0
NSTextCellType = 1
NSImageCellType = 2

# Cell Format for Numeric Data
NSAnyType = 0
NSIntType = 1
NSPositiveIntType = 2
NSFloatType = 3
NSPositiveFloatType = 4
NSDateType = 5
NSDoubleType = 6  
NSPositiveDoubleType = 7

# NSCellImagePosition
NSNoImage = 0 
NSImageOnly = 1
NSImageLeft = 2
NSImageRight = 3
NSImageBelow = 4
NSImageAbove = 5
NSImageOverlaps = 6


# NSCellAttribute {
NSCellDisabled = 0
NSCellState = 1
NSPushInCell = 2
NSCellEditable = 3
NSChangeGrayCell = 4
NSCellHighlighted =    5
NSCellLightsByContents =   6
NSCellLightsByGray =    7
NSChangeBackgroundCell =   8
NSCellLightsByBackground =   9
NSCellIsBordered =   10
NSCellHasOverlappingImage =  11 
NSCellHasImageHorizontal =   12
NSCellHasImageOnLeftOrBottom =  13
NSCellChangesContents =   14
NSCellIsInsetButton = 15
NSCellAllowsMixedState = 16

# When a button is pressed, what happens is...
NSNoCellMask			= 0
NSContentsCellMask		= 1
NSPushInCellMask		= 2
NSChangeGrayCellMask		= 4
NSChangeBackgroundCellMask	= 8


# We try to do as in MAC OS X - Cell State
NSOffState			= 0
NSOnState			= 1
NSMixedState			= -1
