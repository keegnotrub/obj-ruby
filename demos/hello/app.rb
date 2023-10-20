#!/usr/bin/env ruby

require "bundler/setup"

require "obj_ruby"
require "obj_ruby/app_kit"

ObjRuby.initialize!(__dir__)

app = ObjRuby::NSApplication.sharedApplication
app.setMenu(ObjRuby::NSMenu.standard)
app.setActivationPolicy(ObjRuby::NSApplicationActivationPolicyRegular)
app.activateIgnoringOtherApps(true)
app.setDelegate(AppDelegate.new)
app.run

exit
