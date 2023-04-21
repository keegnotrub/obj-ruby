#   NSArrayTest: test of Rigs::NSArray
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
ObjRuby.import("NSString")
ObjRuby.import("NSArray")
ObjRuby.import("NSMutableArray")

class NSArrayTest
  def self.compareRubyArrays(one, two, expectedResult)
    output = "* "

    descriptionOfOne = one.to_s
    descriptionOfTwo = if !two.nil?
      two.to_s
    else
      "(nil)"
    end

    result = (one == two)
    puts one.inspect
    puts two.inspect
    puts "result #{result}"

    output += descriptionOfOne + " and " + descriptionOfTwo
    output += if result
      " are equal"
    else
      " are not equal"
    end

    if result != expectedResult
      output += " ==> test FAILED"
      puts output
      exit 1
    else
      output += " ==> test passed"
      puts output
    end
  end

  def self.compare(one, two, expectedResult)
    output = "* "

    descriptionOfOne = one.to_s
    descriptionOfTwo = if !two.nil?
      two.to_s
    else
      "(nil)"
    end

    result = one.isEqualToArray(two)

    output += descriptionOfOne + " and " + descriptionOfTwo
    output += if result
      " are equal"
    else
      " are not equal"
    end

    if result != expectedResult
      output += " ==> test FAILED"
      puts output
      exit 1
    else
      output += " ==> test passed"
      puts output
    end
  end

  def self.count(array, count)
    description = array.to_s
    result = array.count

    output = "#{description} contains #{result} elements"

    if result != count
      output += " ==> test FAILED"
      puts output
      exit 1
    else
      output += " ==> test passed"
      puts output
    end
  end

  def self.indexOf(array, object, position, range = nil)
    description = array.to_s
    result = if range
      array.indexOfObject_inRange(object, range)
    else
      array.indexOfObject(object)
    end

    output = "#{object} is at index #{result} in array #{description}"
    if range
      output += " in range #{range}"
    end

    if result != position
      output += " ==> test FAILED"
      puts output
      exit 1
    else
      output += " ==> test passed"
      puts output
    end
  end

  def self.main
    # Create two NSArray
    arrayOne = NSArray.new
    arrayTwo = NSArray.new

    # Add numbers to the first one
    arrayOne = arrayOne.arrayByAddingObject("one")
    arrayOne = arrayOne.arrayByAddingObject("two")
    arrayOne = arrayOne.arrayByAddingObject("three")
    arrayOne = arrayOne.arrayByAddingObject("four")

    # dd letters to the second one
    arrayTwo = arrayTwo.arrayByAddingObject("A")
    arrayTwo = arrayTwo.arrayByAddingObject("B")
    arrayTwo = arrayTwo.arrayByAddingObject("C")
    arrayTwo = arrayTwo.arrayByAddingObject("D")
    arrayTwo = arrayTwo.arrayByAddingObject("E")

    # Force the system to garbage-collect now
    # (Why do that in Ruby ??)
    # System.gc ()
    # GC.start

    # Print out description
    puts "Created two NSArrays:"
    puts "* The first one is  #{arrayOne}"
    puts "* The second one is  #{arrayTwo}"
    puts

    # Now trying to count arrays */
    puts "Now trying if count () works"
    count(arrayOne, 4)
    count(arrayTwo, 5)
    puts

    # Now trying if indexOf: works
    puts "Now trying if indexOfObject () works"
    indexOf(arrayOne, "one", 0)
    indexOf(arrayOne, "two", 1)
    indexOf(arrayOne, "three", 2)
    indexOf(arrayOne, "four", 3)
    indexOf(arrayTwo, "C", 2)
    indexOf(arrayTwo, "F", NSNotFound)
    puts

    # Now trying if indexOf:inRange: works
    # Range not yet implemented (_C_STRUCT_B conversion)
    puts "Now trying if indexOfObject_inRange (,) overloaded with the range works"
    indexOf(arrayOne, "one", 0, NSRange.new(0, 3))
    indexOf(arrayOne, "two", 1, NSRange.new(0, 2))
    indexOf(arrayOne, "three", 2, NSRange.new(1, 2))
    indexOf(arrayOne, "four", 3, NSRange.new(3, 1))
    indexOf(arrayTwo, "C", 2, NSRange.new(1, 2))
    puts

    # Right, now test if equality works */
    puts "Now trying to compare the arrays using isEqualToArray ()"
    compare(arrayOne, arrayTwo, false)
    compare(arrayTwo, arrayOne, false)
    compare(arrayOne, arrayOne, true)
    compare(arrayTwo, arrayTwo, true)
    puts

    # Now try cloning  - (Object duplication not implemented yet)
    puts "Now trying to clone () #{arrayOne}"
    arrayTwo = arrayOne.dup
    puts "Comparing the original array and its clone"
    compare(arrayOne, arrayTwo, true)
    puts

    # OK, then write it to a file and read it back. */
    puts "Now writing to file \"test.array\""
    arrayOne.writeToFile_atomically("test.array", true)
    puts "Now loading array from file \"test.array\""
    arrayTwo = NSArray.new("test.array")
    puts "Comparing the original array and the one read from file"
    compare(arrayOne, arrayTwo, true)
    puts

    # Now trying to extract the contents of the NSArray as a Ruby array
    puts
    puts "Now trying to get the contents of an NSArray as a Ruby array"
    rb_arrayOne = arrayOne.objects
    i = 0
    while i < rb_arrayOne.length
      puts "Object at index #{i} is #{rb_arrayOne[i]}"
      i += 1
    end

    #  Now trying to create an NSArray using the special constructor
    #  taking a Ruby array as argument
    puts
    puts "Now trying to create an NSArray from a Ruby array"
    arrayOne = NSArray.new(rb_arrayOne)
    i = 0
    while i < arrayOne.count
      puts "Object at index #{i} is #{arrayOne.objectAtIndex(i)}"
      i += 1
    end

    puts
    puts "Getting the Ruby array from the object and comparing with the original one"
    new_rb_arrayOne = arrayOne.objects
    compareRubyArrays(rb_arrayOne, new_rb_arrayOne, true)

    puts
    puts "Creating a mutable and a non mutable NSArray from the same java array"
    arrayOne = NSMutableArray.new(["testA", "testB", "testC"])
    arrayTwo = NSArray.new(["testA", "testB", "testC"])

    puts "Getting a java array out of them and comparing the two"
    rb_arrayOne = arrayOne.objects
    rb_arrayTwo = arrayTwo.objects

    compareRubyArrays(rb_arrayOne, rb_arrayTwo, true)

    # Happy end */
    puts "test passed"
  end
end

NSArrayTest.main
