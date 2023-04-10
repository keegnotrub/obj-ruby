# NSPoint- Define a fake NSPoint class and methods that go with it
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

require 'obj_ruby/CStruct'

class NSPoint < CStruct

    # Define a "fake" new method that simply returns 
    # a CStruct (Not a NSPoint)
    #def initialize(x,y)
    def NSPoint.new(x,y)
	newPoint = CStruct[x,y]
	if (newPoint._validPoint?)
	    return newPoint
	else
	    raise ArgumentError,"NSPoint 'x' or 'y' argument not valid", caller
	end	
    end

end


class CStruct

    def equalToPoint? (aPoint)
	self == aPoint
    end

    def distanceToPoint (aPoint)
	Math.sqrt((self.x - aPoint.x)**2 + (self.y - aPoint.y)**2)
    end

    def mouseInRect (aRect, flipped)
	if (flipped)
	    ( (self.x >= aRect.minX) && (self.y >= aRect.minY) &&
	      (self.x < aRect.maxX)  && (self.y < aRect.maxY) ) 
	else
	    ( (self.x >= aRect.minX) && (self.y > aRect.minY) &&
	      (self.x < aRect.maxX)  && (self.y <= aRect.maxY) ) 
	end
    end

    def pointInRect?(aRect)
	self.mouseInRect?(aRect, true)
    end

    def _validPoint?
	( (self.kind_of? CStruct) && (self.array_size == 2) &&
	(self[0].kind_of? Numeric) && (self[1].kind_of? Numeric) )
    end

end

NSZeroPoint = NSPoint.new(0,0)
