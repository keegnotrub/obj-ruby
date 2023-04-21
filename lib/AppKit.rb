# Appkit.rb - Load all AppKit GUI classes at once
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
#

# Make sure Foundation classes are loaded first
require 'Foundation'

AppKitClasses = [ 
"NSActionCell",
"NSAffineTransform",
"NSApplication",
"NSAttributedString",
"NSBezierPath",
"NSBitmapImageRep",
"NSBox",
"NSBrowser",
"NSBrowserCell",
"NSButton",
"NSButtonCell",
"NSCachedImageRep",
"NSCStringText",
"NSCell",
"NSClipView",
"NSColor",
"NSColorList",
"NSColorPanel",
"NSColorPicker",
"NSColorPicking",
"NSColorWell",
"NSComboBox",
"NSComboBoxCell",
"NSControl",
"NSCursor",
"NSCustomImageRep",
"NSDataLink",
"NSDataLinkManager",
"NSDataLinkPanel",
"NSDragging",
"NSEPSImageRep",
"NSEvent",
"NSFont",
"NSFontManager",
"NSFontPanel",
"NSForm",
"NSFormCell",
"NSGraphicsContext",
"NSHelpPanel",
"NSImage",
"NSImageCell",
"NSImageRep",
"NSImageView",
"NSInterfaceStyle",
"NSMatrix",
"NSMenu",
"NSMenuItem",
"NSMenuItemCell",
"NSMenuView",
"NSNibLoading",
"NSOpenPanel",
"NSPageLayout",
"NSPanel",
"NSParagraphStyle",
"NSMutableParagraphStyle",
"NSPasteboard",
"NSPopUpButton",
"NSPopUpButtonCell",
"NSPrinter",
"NSPrintInfo",
"NSPrintOperation",
"NSPrintPanel",
"NSProgressIndicator",
"NSResponder",
"NSSavePanel",
"NSScreen",
"NSScroller",
"NSScrollView",
"NSSecureTextField",
"NSSelection",
"NSSlider",
"NSSliderCell",
"NSSpellChecker",
"NSSpellProtocol",
"NSSpellServer",
"NSSplitView",
"NSStepper",
"NSStepperCell",
"NSStringDrawing",
"NSTableColumn",
"NSTableHeaderCell",
"NSTableHeaderView",
"NSTableView",
"NSTabView",
"NSTabViewItem",
"NSText",
"NSTextField",
"NSTextFieldCell",
"NSTextView",
"NSView",
"NSWindow",
"NSWorkspace",
"NSNibDeclarations",
"NSDrawer",
"NSLayoutManager",
"NSTextContainer",
"NSTextStorage",
"NSUserInterfaceValidation",
"NSWindowController" ]

# Now import them all
AppKitClasses.each { |aClass|  ObjRuby.import(aClass) }

