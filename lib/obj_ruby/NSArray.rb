# NSArray.rb - Add a couple of things to the NSArray class
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


NSArray = ObjRuby.class("NSArray")

module ObjRuby


    class << NSArray
	remove_method :new
   
	#
	# Now redefine the new method. If new has a Ruby Array as argument
	# then transform it into a NSArray . If it is a string then take it as
	# a file name and load the content in the new NSArray
	#
	def new (arg = nil)

	    if (arg.kind_of? Array)
		return self.arrayWithRubyArray(arg)
	    elsif (arg.kind_of? String)
		return self.arrayWithContentsOfFile(arg)
	    elsif (arg.kind_of? NSArray)
		return self.arrayWithArray(arg)
	    else
		return self.array
	    end

	end
    end


    class NSArray

	#
	# return all the objects of an NSArray in a native Ruby Array
	#
	def objects
	    size = self.count
	    i=0
	    rb_ary = []
	    while i<size
		rb_ary.push(self.objectAtIndex(i))
		i += 1
	    end
	    return rb_ary
	end

	#
	# ObjC count method is identical to Ruby length (or size)
	def length
	    self.count
	end
	def size
	    self.count
	end

	#
	# Redefine the indexing method to suit Ruby syntax
	#
	def [] (index)
	    self.objectAtIndex(index)
	end

	#
	# Redefine the == method to suit Ruby syntax
	#
	def == (array)

	    return false if !(array.kind_of? NSArray)

	    i=0
	    while i< array.length
		return false if (self[i] != array[i])
		i += 1
	    end
	    return true
	end
	
    end
 
end


