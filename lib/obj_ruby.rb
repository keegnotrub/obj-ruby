# obj_ruby.rb - Main file to require to start using ObjRuby
#
# The initial boot strap code for ObjRuby. It preloads
# some of the Objective-C classes and sometimes
# wraps some ruby code around it.
#
# $Id$
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

require 'obj_ext'

#
# Invoking AT"a string..." in Ruby will automatically generate
# a NSString (the '@' sign can't be used as in GNUstep
# because it is a reserved character for instance and class
# variables. AT has no effect if String autoconversion is ON
#
def AT(stg)
  if ($STRING_AUTOCONVERT)
	  return stg
  else
	  return NSString.stringWithCString(stg)
  end
end

#
# selector is a shortcut to NSSelector#new
# (mimics @selector in Objective C)
#
def selector(selString)
  return NSSelector.new(selString)
end


module ObjRuby

  #
  # Determine if the class is already loaded		
  # if not then load obj_ruby/classname.rb if it exists
  # if it doesn't then just invoke ObjRuby.class("classname")
  #
  # - if NSxxxx top level constant defined than it means we have
  #    already gone through a full regular import from the Ruby side
  #    so there is no nedd to import again
  # - Try and load NSxxxx.rb file. If ok then return else if no Ruby code...
  # - Load the class (ObjRuby.class)
  # - if the NSxxxx is not defined then define it (we need to test for the
  #    existence of NSxxxx top level constant because ObjRuby.class goes to
  #    Objective C which then call ObjRuby.import again
  #
  # This mechanism makes sure that the Ruby code for a given NSxxxx
  # class is  loaded ok whether the class is imported from the Ruby side
  # with import or automagically registered from Objective C
  def ObjRuby.import(className)
	  begin
	    isClassDefined = Object.const_defined? className

	    if not isClassDefined
		    classFile = "obj_ruby/#{className}.rb"
		    begin
		      result = require classFile
		    rescue LoadError
		      rbClass = ObjRuby.class(className)
		      if !(Object.const_defined? className)
			      Object.const_set(className, rbClass)
		      end
		    end
	    end
	  rescue NameError
	    # The className is (probably) not a constant name
	    # Some GNUstep class names start with an underscore which
	    # is not understood as a Constant by Ruby. Hence the exception
	    # The Class is however defined ok. It is simply not explicitely
	    # accessible from the Ruby Side.
	    puts "Warning: ObjRuby.import says #{className} is not a Constant - Doing nothing"
	  end 

  end

end

# Systematically load these "pseudo" or Ruby only classes
require 'obj_ruby/NSRange.rb'
require 'obj_ruby/NSPoint.rb'
require 'obj_ruby/NSSize.rb'
require 'obj_ruby/NSRect.rb'
require 'obj_ruby/NSSelector.rb'


# Set it to true if you want all Ruby String arguments
# to be automatically transformed to NSString
# and returned NSString object transformed to Ruby String
$STRING_AUTOCONVERT = false

# Set it to true if you want to bothe express SELectors with
# simple strings in Ruby or conversely have an ObjC sel
# returned as a String
# In all cases you can invoke selector("selectorString:") in Ruby
# to generate a selector.
$SELECTOR_AUTOCONVERT = false

# Set it to true if you want ObjC NSNumbers return values
# to be automatically transformed into a Ruby numberl
# In all cases Ruby numbers passed to ObjC are automatically
# morphed to NSNumber when ObjC expects an id as argument
$NUMBER_AUTOCONVERT = false
