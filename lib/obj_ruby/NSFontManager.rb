# NSFontManager.rb - Add a couple of things to the Objective C NSFontManager class
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
  # NSFontTraitMask
  NSItalicFontMask = 1
  NSUnitalicFontMask = 0 # 1024
  NSBoldFontMask = 2
  NSUnboldFontMask = 0 # 2048
  NSNarrowFontMask = 4
  NSExpandedFontMask = 8
  NSCondensedFontMask = 16
  NSSmallCapsFontMask = 32
  NSPosterFontMask = 64
  NSCompressedFontMask = 128
  NSNonStandardCharacterSetFontMask = 256
  NSFixedPitchFontMask = 512

  # NSFontTag
  NSNoFontChangeAction = 0
  NSViaPanelFontAction = 1
  NSAddTraitFontAction = 2
  NSRemoveTraitFontAction = 3
  NSSizeUpFontAction = 4
  NSSizeDownFontAction = 5
  NSHeavierFontAction = 6
  NSLighterFontAction = 7
end
