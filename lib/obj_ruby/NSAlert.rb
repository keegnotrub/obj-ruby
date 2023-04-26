# NSAlert.rb - Add a couple of things to the Objective C NSAlert class
#
#  $Id$
#
#    Copyright (C) 2023 thoughtbot, Inc.
#   
#    Written by:  Ryan Krug <ryan.krug@thoughtbot.com>
#    Date: April 2023
#   
#    This file is part of the GNUstep Ruby Interface Library.
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

NSAlert = ObjRuby.class("NSAlert")

NSAlertStyleWarning = 0
NSAlertStyleInformational = 1
NSAlertStyleCritical = 2