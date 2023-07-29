require "bundler/setup"
Bundler.setup

require "obj_ruby"
require "obj_ruby/app_kit"

require_relative "app_delegate"

app = ObjRuby::NSApplication.sharedApplication
app.setActivationPolicy ObjRuby::NSApplicationActivationPolicyRegular
app.activateIgnoringOtherApps(true)

app.setDelegate(AppDelegate.new)

app.run

exit
