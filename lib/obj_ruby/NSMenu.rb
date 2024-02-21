# NSMenu.rb - Add a couple of things to the NSMenu class
#
#  $Id$
#
#    Copyright (C) 2023 thoughtbot
#
#    Written by:  Ryan Krug <ryan.krug@thoughtbot.com>
#    Date: October 2023
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

module ObjRuby
  class NSMenu
    def self.shared
      @shared ||= new
    end

    def draw(&block)
      removeAllItems
      instance_exec(&block)

      self
    end

    def menu(title = "", &block)
      submenu = self.class.alloc.initWithTitle(title)
      submenu.draw(&block)

      wrapper = NSMenuItem.new
      wrapper.setSubmenu(submenu)
      addItem(wrapper)

      self
    end

    def item(title = "", action = nil, key = "")
      addItem(NSMenuItem.alloc.initWithTitle_action_keyEquivalent(title, action, key))

      self
    end

    def separator
      addItem(NSMenuItem.separatorItem)

      self
    end
  end
end
