# frozen_string_literal: true

# cocoa.rb - Load Cocoa Framework
#
# Written by:  Ryan Krug <ryank@kit.com>
# Date: May 2023
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

ObjRuby.require_framework("Foundation")
ObjRuby.require_framework("CoreData")
ObjRuby.require_framework("AppKit")
