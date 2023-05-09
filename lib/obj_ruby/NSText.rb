# NSText.rb - Add a couple of things to the Objective C NSText class
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

module ObjRuby
  # NSTextAlignment;
  NSLeftTextAlignment = 0
  NSRightTextAlignment = 1
  NSCenterTextAlignment = 2
  NSJustifiedTextAlignment = 3
  NSNaturalTextAlignment = 4

  # Text Movement
  NSIllegalTextMovement	= 0
  NSReturnTextMovement	= 0x10
  NSTabTextMovement	= 0x11
  NSBacktabTextMovement	= 0x12
  NSLeftTextMovement	= 0x13
  NSRightTextMovement	= 0x14
  NSUpTextMovement	= 0x15
  NSDownTextMovement	= 0x16

  # Special Characters
  NSParagraphSeparatorCharacter	= 0x2029
  NSLineSeparatorCharacter	= 0x2028
  NSTabCharacter = 0x0009
  NSFormFeedCharacter	= 0x000c
  NSNewlineCharacter	= 0x000a
  NSCarriageReturnCharacter	= 0x000d
  NSEnterCharacter	= 0x0003
  NSBackspaceCharacter	= 0x0008
  NSBackTabCharacter	= 0x0019
  NSDeleteCharacter	= 0x007f
end
