#   NSDateTest: test of Rigs::NSDate
#
#    Copyright (C) 2000 Free Software Foundation, Inc.
#
#    Author:  Laurent Julliard <laurent@julliard-online.org>
#             (inspired from Nicola Pero's JIGS test file)
#    Date: September 2001
#
#    This file is part of GNUstep.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

require "bundler/setup"
Bundler.setup

require "obj_ruby"
ObjRuby.import("NSDate")

$STRING_AUTOCONVERT = true

# Create a new date
dateOne = NSDate.new
dateTwo = dateOne
puts
puts " * Created date: #{dateOne}"

dateOne = dateOne.addTimeInterval(2)
puts "   Adding 2 seconds it becomes:  #{dateOne}"
dateOne = dateOne.addTimeInterval(120)
puts "   Adding 2 minutes it becomes:  #{dateOne}"
dateOne = dateOne.addTimeInterval(7200)
puts "   Adding 2 hours it becomes: #{dateOne}"

# Print out time interval since reference date
print "   Time interval since reference date: ", dateOne.timeIntervalSinceReferenceDate, "\n"
print "   Time interval since now: ", dateOne.timeIntervalSinceNow, "\n"

puts
puts " * When the program started it was: #{dateTwo}"
puts
print " * And the earlier date of the two is: ", dateTwo.earlierDate(dateOne), "\n"
puts

if dateTwo.earlierDate(dateOne) != dateTwo
  puts "==> Test failed"
  exit 1
end

# Happy end
puts "test passed"
