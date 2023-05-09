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
  def self.import(class_name)
    if const_defined?(class_name)
      const_get(class_name)
    else
      self.class(class_name)
    end
  end

  def self.extend_class(class_name)
    require "obj_ruby/#{class_name}"
  rescue LoadError
    # Not extended by ObjRuby
  end

  def self.require_framework(framework)
    case framework
    when "Foundation"
      FOUNDATION.map { |class_name| import(class_name) }
    when "AppKit"
      FOUNDATION.each { |class_name| import(class_name) }
      APP_KIT.map { |class_name| import(class_name) }
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
