# NSRange- Define a fake NSRange class and methods that go with it
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

class NSRange < CStruct

    # Define a "fake" new method that simply returns 
    # a CStruct object
    def NSRange.new(location, length)
	newRange = CStruct[location, length]
    	if (newRange._validRange?)
	    return newRange
	else
	    raise ArgumentError,"NSRange 'location' or 'length' argument not valid", caller
	end
    end

end

# These methods cannot be defined in NSRange because Obj C structures
# are not typed and always returned as CStruct never as NSRange.
class CStruct
    
    def location
	self[0]
    end

    def location= (aLocation)
	self[0] = aLocation
    end

    def length
	self[1]
    end

    def length= (aLength)
	self[1] = aLength
    end

    def equalToRange? (aRange)
	self == aRange
    end


    def locationInRange (aLocation)
	return ((aLocation >= self.location) && (aLocation < (self.location + self.rlength)) )
    end

    def maxRange
	return (self.location + self.rlength)
    end

    def subrangeOfRange? (aRange)
	return (self.location >= aRange.location) &&
	    (self.location + self.rlength < (aRange.location + aRange.rlength))
    end
  
    def emptyRange?
	(self.rlength == 0)
    end

    def rangeByIntersectingRange (aRange)
	newRange = self.dup
	return newRange.intersectRange(aRange);
    end

    def rangeByUnioningRange (aRange)
	newRange = self.dup
	return newRange.unionRange!(aRange);
    end


    def intersectRange! (aRange)

	if (self.location > aRange.location)
	    newLocation = self.location
	else
	    newLocation = aRange.location
    
	    maxRange1 = self.location + self.rlength;
	    maxRange2 = aRange.location + aRange.rlength
	end
    
	if (maxRange1 < maxRange2)
	    newLength = maxRange1 - self.location
	else
	    newLength = maxRange2 - aRange.location
	end

	self.location = newLocation
	self.rlength = newLength
    end

    def unionRange! (aRange)
	
	if (self.location < aRange.location)
	    newLocation = self.location
	else
	    newLocation = aRange.location
	end

	maxRange1 = self.location + self.rlength
	maxRange2 = aRange.location + aRange.rlength
   
	if (maxRange1 > maxRange2)
	    newLength = maxRange1 - self.location
	else
	    newLength = maxRange2 - aRange.location
	end

	self.location = newLocation
	self.rlength = newLength
    end

    def _validRange?
	(self.kind_of? CStruct) && (self.array_size == 2) &&
	(self[0].kind_of? Integer) && (self[1].kind_of? Integer)
    end

end

NSZeroRange = NSRange.new(0,0)
