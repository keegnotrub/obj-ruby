# CStruct.rb - Specific ruby class to handle Obj C structure
#
# $Id$
#
# This is a simple sub class of Array to handle C structures
# coming from or going to Objective C. All arguments that must be passed
# to Objective C as a C structure must be created with CStruct.new or
# CStruct[] (see  NSRect, NSSize, NSPoint and NSRange for an example)
#
#   Copyright (C) 2001 Free Software Foundation, Inc.
#
#   Written by:  Laurent Julliard <laurent@julliard-online.org>
#   Date: Aug 2001
#   
#   This file is part of the GNUstep Ruby  Interface Library.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Library General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#   
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Library General Public License for more details.
#   
#   You should have received a copy of the GNU Library General Public
#   License along with this library; if not, write to the Free
#   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
#

# For method definitions see NSRect, NSSize, NSPoint and NSRange
# ruby files. This is basically an empty class definition here, because
# initialize and the [] constructor goes directly to the super class

class CStruct < Array
    alias_method :array_size, :size
    alias_method :array_length, :length
end
