# NSPrintPanel.rb - Add a couple of things to the Objective C NSPrintPanel class
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

NSPrintPanel = ObjRuby.class("NSPrintPanel")


# dentifying the NSViews in a print panel
NSPPSaveButton		= 0
NSPPPreviewButton	= 1
NSFaxButton		= 2
NSPPTitleField		= 3
NSPPImageButton		= 4
NSPPNameTitle		= 5
NSPPNameField		= 6
NSPPNoteTitle		= 7
NSPPNoteField		= 8
NSPPStatusTitle		= 9
NSPPStatusField		= 10
NSPPCopiesField		= 11
NSPPPageChoiceMatrix	= 12
NSPPPageRangeFrom	= 13
NSPPPageRangeTo		= 14
NSPPScaleField		= 15
NSPPOptionsButton	= 16
NSPPPaperFeedButton	= 17
NSPPLayoutButton	= 18
