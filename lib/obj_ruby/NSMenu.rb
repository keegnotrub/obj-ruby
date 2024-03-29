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
    def self.standard
      menu_bar = new

      app_menu = new
      app_menu.addItem(NSMenuItem.alloc.initWithTitle_action_keyEquivalent("Quit", "terminate:", "q"))

      app_menu_item = NSMenuItem.new
      app_menu_item.setSubmenu(app_menu)

      menu_bar.addItem(app_menu_item)
      menu_bar
    end
  end
end
