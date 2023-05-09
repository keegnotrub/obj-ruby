# NSColorPanel.rb - Add a couple of things to the Objective C NSColorPanel class
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
  NSGrayModeColorPanel = 0
  NSRGBModeColorPanel = 1
  NSCMYKModeColorPanel = 2
  NSHSBModeColorPanel = 3
  NSCustomPaletteModeColorPanel = 4
  NSColorListModeColorPanel = 5
  NSWheelModeColorPanel = 6

  NSColorPanelGrayModeMask = 1
  NSColorPanelRGBModeMask = 2
  NSColorPanelCMYKModeMask = 4
  NSColorPanelHSBModeMask = 8
  NSColorPanelCustomPaletteModeMask = 16
  NSColorPanelColorListModeMask = 32
  NSColorPanelWheelModeMask = 64
  NSColorPanelAllModesMask = 127
end
