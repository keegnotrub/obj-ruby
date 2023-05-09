# NSImageCell.rb - Add a couple of things to the Objective C NSImageCell class
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
  # NSImageScaling
  NSScaleProportionally = 0   # Fit propoRtionally
  NSScaleToFit = 1            # Forced fit (distort if necessary)
  NSScaleNone = 2             # Don't scale (clip)

  # NSImageAlignment
  NSImageAlignCenter = 0
  NSImageAlignTop = 1
  NSImageAlignTopLeft = 2
  NSImageAlignTopRight = 3
  NSImageAlignLeft = 4
  NSImageAlignBottom = 5
  NSImageAlignBottomLeft = 6
  NSImageAlignBottomRight = 7
  NSImageAlignRight = 8

  # NSImageFrameStyle
  NSImageFrameNone = 0
  NSImageFramePhoto = 1
  NSImageFrameGrayBezel = 2
  NSImageFrameGroove = 3
  NSImageFrameButton = 4
end
