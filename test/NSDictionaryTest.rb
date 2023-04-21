#   NSDictionaryTest: test of Rigs::NSDictionary
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
ObjRuby.import("NSDictionary")
ObjRuby.import("NSMutableDictionary")

class NSDictionaryTest
  def self.main
    # Create a NSMutableDictionary
    puts "Creating a mutable dictionary and putting stuff in it..."
    dictionaryOne = NSMutableDictionary.new

    dictionaryOne.setObject_forKey("value1", "key1")
    dictionaryOne.setObject_forKey("value2", "key2")
    dictionaryOne.setObject_forKey("value1", "key3")
    dictionaryOne.setObject_forKey("value2", "key4")
    dictionaryOne.setObject_forKey("value1", "key5")
    dictionaryOne.setObject_forKey("value2", "key1")

    puts "Got #{dictionaryOne}"
    puts ""

    puts "Creating a dictionary from the first one"
    dictionaryTwo = NSDictionary.new(dictionaryOne)
    puts "Got #{dictionaryTwo}"
    puts ""

    puts "Getting the keys"
    arrayOne = dictionaryTwo.allKeys
    puts "Got #{arrayOne}"
    puts ""

    puts "For each key, getting the value and checking it's value1 or value2"
    i = 0
    while i < arrayOne.count

      object = dictionaryOne.objectForKey(arrayOne.objectAtIndex(i))

      if !object.isEqual("value1") && !object.isEqual("value2")
        puts "#{object} is not value1 or value2"
        puts "==> test failed"
        exit 1
      end
      i += 1
    end
    puts "Yes - check passed"
    puts ""

    puts "Now creating a dictionary from two java arrays"
    dictionaryTwo = NSDictionary.new({
      "key0" => "value0",
      "key1" => "value1"
    })
    puts "Got #{dictionaryTwo}"

    puts "Now testing removeObjectForKey()"
    dictionaryOne = NSMutableDictionary.new

    dictionaryOne.setObject_forKey("value1", "key1")
    if !dictionaryOne.objectForKey("key1").isEqual("value1")
      puts "setObject_forKey didn't work"
      puts "==> test failed"
      exit 1
    end
    dictionaryOne.removeObjectForKey("key1")
    if !dictionaryOne.objectForKey("key1").nil?
      puts "removeObjectForKey didn't work"
      puts "==> test failed"
      exit 1
    end

    puts "Now testing mutableCopy ()"
    tmpDict = NSDictionary.new({"key1" => "value1"})
    dictionaryOne = tmpDict.mutableCopy
    if !dictionaryOne.objectForKey("key1").isEqual("value1")
      puts "mutableCopy didn't work"
      puts "==> test failed"
      exit 1
    end

    # a bit of clean up (why ?)
    GC.start

    dictionaryOne.removeObjectForKey("key1")
    if !dictionaryOne.objectForKey("key1").nil?
      puts "removeObjectForKey didn't work"
      puts "==> test failed"
      exit 1
    end

    # Happy end
    puts "test passed"
  end
end

NSDictionaryTest.main
