# NSDictionary.rb - Add a couple of things to the NSDictionary class
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

NSDictionary = ObjRuby.class("NSDictionary")

module ObjRuby

    # undefine the default new method that was registered
    # from the Objective C side of ObjRuby
    class << NSDictionary
	remove_method :new
    end
    
    class NSDictionary

	#
	# Now redefine the new method. If new has a Ruby Dictionary as argument
	# then transform it into a NSDictionary . If it is a string then take it as
	# a file name and load the content in the new NSDictionary
	#
	def NSDictionary.new (arg = nil)
	    #puts "In NSDictionay.new arg is of type #{arg.type}"
	    if (arg.kind_of? Hash)
		return self.dictionaryWithRubyHash(arg)
	    elsif (arg.kind_of? String)
		return self.dictionaryWithContentsOfFile(arg)
	    elsif (arg.kind_of? NSDictionary)
		return self.dictionaryWithDictionary(arg)
	    else
		return self.dictionary
	    end

	end
	    
	#
	# return all the objects of an NSDictionary in a native Ruby Dictionary
	#
	def keys
	    self.allKeys
	end
	def values
	    self.allValues
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
	def [] (key)
	    self.objectForKey(key)
	end

	#
	# Redefine the == method to suit Ruby syntax
	#
	def == (hash)

	    if (hash.kind_of? NSDictionary)
		return self.isEqualToDictionary(hash)
	    else
		return false
	    end

	end
	
    end
    
end


