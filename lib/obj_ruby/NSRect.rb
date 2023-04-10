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

require 'obj_ruby/CStruct'
require 'obj_ruby/NSPoint'
require 'obj_ruby/NSSize'

class NSRect < CStruct

    # Define a "fake" new method that simply returns 
    # an array
    def NSRect.new(x=0,y=0,width=0,height=0)
	CStruct[NSPoint.new(x,y), NSSize.new(width,height)]
    end

end

class CStruct

    def x
	if ( self[0].kind_of? CStruct )
	    # it is a Rectangle
	    self[0][0]
	elsif ( self[0].kind_of? Numeric )
	    #it is a point
	    self[0]
	else
	    raise ArgumentError,"x is neither an CStruct nor a Number", caller
	end
    end

    def x= (anX)
	if ( self[0].kind_of? CStruct )
	    if ( !anX.kind_of? Numeric )
		raise ArgumentError,"NSRect 'x' is not a number", caller
	    end
	    self[0][0] = anX
	elsif ( self[0].kind_of? Numeric )
	    if ( !anX.kind_of? Numeric )
		raise ArgumentError,"NSPoint 'x' is not a number", caller
	    end
	    self[0] = anX
	else
	    raise ArgumentError,"x is neither an CStruct nor a Number", caller
	end
    end

    def y
	if ( self[0].kind_of? CStruct )
	    self[0][1]
	elsif ( self[1].kind_of? Numeric )
	    self[1]
	else
	    raise ArgumentError,"y is neither an CStruct nor a Number", caller
	end
    end

    def y= (anY)
	if ( self[0].kind_of? CStruct )
	    if ( !anY.kind_of? Numeric )
		raise ArgumentError,"NSRect 'y' is not a number", caller
	    end
	    self[0][1] = anY
	elsif ( self[1].kind_of? Numeric )
	    if ( !anY.kind_of? Numeric )
		raise ArgumentError,"NSPoint 'y' is not a number", caller
	    end
	    self[1] = anY
	else
	    raise ArgumentError,"y is neither an CStruct nor a Number", caller
	end
    end

    def width
	if ( self[1].kind_of? CStruct )
	    # it is a Rect
	    self[1][0]
	elsif ( self[0].kind_of? Numeric )
	    # it is a Size
	    self[0]
	else
	    raise ArgumentError,"width is neither an CStruct nor a Number", caller
	end
    end
 
    def width= (aWidth)
	if ( self[1].kind_of? CStruct )
	    if ( !aWidth.kind_of? Numeric )
		raise ArgumentError,"NSRect 'width' is not a number", caller
	    end
	    self[1][0] = aWidth
	elsif ( self[0].kind_of? Numeric )
	    if ( !aWidth.kind_of? Numeric )
		raise ArgumentError,"NSSize 'width' is not a number", caller
	    end
	    self[0] = aWidth
	else
	    raise ArgumentError,"width is neither an CStruct nor a Number", caller
	end
    end

    def height
	if ( self[1].kind_of? CStruct )
	    # it is a Rect
	    self[1][1]
	elsif ( self[1].kind_of? Numeric )
	    # it is a Size
	    self[1]
	else
	    raise ArgumentError,"height is neither an CStruct nor a Number", caller
	end
    end
 	
    def height= (aHeight)
	if ( self[1].kind_of? CStruct )
	    if ( !aHeight.kind_of? Numeric )
		raise ArgumentError,"NSRect 'height' is not a number", caller
	    end
	    self[1][1] = aHeight
	elsif ( self[1].kind_of? Numeric )
	    if ( !aHeight.kind_of? Numeric )
		raise ArgumentError,"NSSize 'height' is not a number", caller
	    end
	    self[1] = aHeight
	else
	    raise ArgumentError,"height is neither an CStruct nor a Number", caller
	end
    end

    def origin
	if ( self._validRect? )
	    self[0]
	else
	    raise ArgumentError,"origin receiver not a valid NSRect", caller
	end
    end

    def origin= (anOrigin)
	
	if (!anOrigin._validPoint?)
	    raise ArgumentError,"origin argument not a valid NSPoint", caller
	end
	    
	if (self._validRect?)
	    self[0] = anOrigin
	else
	    raise ArgumentError,"receiver is not a valid NSRect", caller
	end
	
    end

    def size
	if ( self._validRect? )
	    self[1]
	else
	    raise ArgumentError,"size  receiver not a valid NSRect", caller
	end
    end

    def size= (aSize)
	
	if (!aSize._validSize?)
	    raise ArgumentError,"size argument not a valid NSSize", caller
	end
	    
	if (self._validRect?)
	    self[1] = aSize
	else
	    raise ArgumentError,"receiver is not a valid NSRect", caller
	end
	
    end

    def maxX
	self.x + self.width
    end

    def midX
	self.x + self.width/2
    end

    def maxY
	self.y + self.height
    end

    def midY
	self.y + self.height/2
    end

    def minX
	self.x
    end

    def minY
	self.y
    end

    def isEqualToRect (aRect)
	self == aRect
    end

    def intersectsRect? (aRect)
	not ( (aRect.x + aRect.width <= self.x)  || 
	      (self.x + self.width <= aRect.x)   ||
	      (aRect.y + aRect.height <= self.y) ||
	      (self.y + self.height <= aRect.y) )
    end
    
    def emptyRect?
	(self.width == 0) || (self.height == 0)
    end

    def containsRect? (aRect)
	( (self.x < aRect.x) && 
	 (self.y < aRect.y)  &&
	 ((self.x + self.width) > (aRect.x + aRect.width)) &&
	 ((self.y + self.height) > (aRect.y + aRect.height)) )
    end

    def containsPoint? (aPoint)
	aPoint.pointInRect?(self)
    end

    def offsetRect!(dx,dy)
	self.x += dx
	self.y += dy
	self
    end

    def insetRect! (dx,dy)
	self.offsetRect(dx,dy)
	self.width -= (2 * dX)
	self.height -= (2 * dY)
	self
    end

    def intersectRect! (aRect)
	
	maxX1 = self.x + self.width
	maxY1 = self.y + self.height
	maxX2 = aRect.x + aRect.width
	maxY2 = aRect.y + aRect.height

	if ((maxX1 <= aRect.x) || (maxX2 <= x) || (maxY1 <= aRect.y) || (maxY2 <= y))
	    self.width = 0
	    self.height = 0
	else

	    if (aRect.x <= self.x)
		newX = self.x
	    else
		newX = aRect.x
	    end

	    if (aRect.y <= self.y)
		newY = self.y
	    else
		newY = aRect.y
	    end
	
	    if (maxX2 >= maxX1)
		newWidth = self.width
	    else
		newWidth = maxX2 - newX
	    end
	
	    if (maxY2 >= maxY1)
		newHeight = self.height
	    else
		newHeight = maxY2 - newY
	    end
	
	    self.x = newX
	    self.y = newY
	    self.width = newWidth
	    self.height = newHeight
	end
	self
    end

    def makeIntegral!
	self.x = Math.floor(self.x)
	self.y = Math.floor(self.y)
	self.width = Math.ceil(self.width)
	self.height = Math.ceil(self.height)
	self
    end

    def unionRect! (aRect)

	return if ((aRect.width == 0) || (aRect.height == 0))
	    
	if ((self.width == 0) || (self.height == 0))
	    self.x = aRect.x
	    self.y = aRect.y
	    self.width = aRect.width
	    self.height = aRect.height
	    self
	end
    
	if (self.x < aRect.x)
	    newX = self.x
	else
	    newX = aRect.x
	end
    
	if (self.y < aRect.y)
	    newY = self.y
	else
	    newY = aRect.y
	end
    
	if ((self.x + self.width) > (aRect.x + aRect.width))
	    newWidth = self.x + self.width - newX
	else
	    newWidth = aRect.x + aRect.width - newX
	end

	if ((self.y + self.height) > (aRect.y + aRect.height))
	    newHeight = self.y + self.height - newY
	else
	    newHeight = aRect.y + aRect.height - newY
	end
	self.x = newX
	self.y = newY
	self.width = newWidth
	self.height = newHeight
	self
    end

    def rectByInsettingRect(dx,dy)
	rect = self.dup
	rect.insetRect!(dx,dy)
	rect
    end

    def rectByIntersectingRect(aRect)
	rect = self.dup
	rect.intersectRect!(aRect)
	rect
    end

    def rectByMakingIntegral
	rect = self.dup
	rect.makeIntegral!
	rect
    end

    def rectByOffsettingRect (dx,dy)
	rect = self.dup
	rect.offsetRect!(dx,dy)
	rect
    end

    def rectByUnioningRect (aRect)
	rect = self.dup
	rect.unionRect!(aRect)
	rect
    end

    def _validRect?
	(self.kind_of? CStruct) && (self.array_size == 2) &&
	self[0]._validPoint? && self[1]._validSize?
    end

end # class definition

NSZeroRect = NSRect.new(0,0,0,0)
