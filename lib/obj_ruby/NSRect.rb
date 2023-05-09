# NSRect- Define a fake NSRect class and methods that go with it
#
#  $Id$
#
#    Copyright (C) 2001 Free Software Foundation, Inc.
#
#    Written by:  Laurent Julliard <laurent@julliard-online.org>
#    Date: September 2001
#
#    This file is part of the GNUstep RubyInterface Library.
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

require "obj_ruby/CStruct"
require "obj_ruby/NSPoint"
require "obj_ruby/NSSize"

module ObjRuby
  class NSRect < CStruct
    def self.new(x = 0, y = 0, width = 0, height = 0)
      CStruct[NSPoint.new(x, y), NSSize.new(width, height)]
    end
  end

  NSZeroRect = NSRect.new(0, 0, 0, 0)
end
