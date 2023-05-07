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

require "obj_ext"

require "obj_ruby/version"
require "obj_ruby/foundation"
require "obj_ruby/app_kit"

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
  def self.import(class_name)
    return if Object.const_defined?(class_name)

    class_file = "obj_ruby/#{class_name}"
    begin
      require class_file
    rescue LoadError
      objc_class = ObjRuby.class(class_name)
      unless Object.const_defined?(class_name)
        Object.const_set(class_name, objc_class)
      end
    end
  end

  def self.require_framework(framework)
    case framework
    when "Foundation"
      FOUNDATION.each { |class_name| import(class_name) }
    when "AppKit"
      FOUNDATION.each { |class_name| import(class_name) }
      APP_KIT.each { |class_name| import(class_name) }
    else
      puts "Warning: ObjRuby.require_framework says #{framework} is not supported - Doing nothing"
    end
  end
end

# Systematically load these "pseudo" or Ruby only classes
require "obj_ruby/NSRange"
require "obj_ruby/NSPoint"
require "obj_ruby/NSSize"
require "obj_ruby/NSRect"
require "obj_ruby/NSSelector"
