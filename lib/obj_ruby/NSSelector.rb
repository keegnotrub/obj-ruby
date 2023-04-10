# NSSelector.rb - Add a couple of things to the Objective C NSSelector class
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

require ('obj_ruby/NSString')

NSSelector = ObjRuby.class("NSSelector")

module ObjRuby

    # undefine the default new method that was registered
    # from the Objective C side of ObjRuby
    class << NSSelector
	remove_method :new
    end
    
    class NSSelector
	# Now redefine the new method (Don't use initialize
	# because it's not a native Ruby object)
	def NSSelector.new (selString)
	    if ($SELECTOR_AUTOCONVERT)
		return(selString)
	    else
		return NSSelector.selectorWithString(AT(selString))
	    end
	end
	
    end

end
