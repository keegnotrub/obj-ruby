# NSFont.rb - Add a couple of things to the Objective C NSFont class
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

NSFont = ObjRuby.class("NSFont")

# Reserved Glyph values
NSControlGlyph = 0x00ffffff
NSNullGlyph = 0x0



# NSGlyphRelation
NSGlyphBelow = 0
NSGlyphAbove = 1


# NSMultibyteGlyphPacking
NSOneByteGlyphPacking = 0
NSJapaneseEUCGlyphPacking =  1
NSAsciiWithDoubleByteEUCGlyphPacking = 2
NSTwoByteGlyphPacking =  3
NSFourByteGlyphPacking = 4
