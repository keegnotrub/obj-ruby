require_relative "environment"

app = ObjRuby::NSApplication.sharedApplication
app.setMenu(ObjRuby::NSMenu.standard)
app.setActivationPolicy(ObjRuby::NSApplicationActivationPolicyRegular)
app.activateIgnoringOtherApps(true)
app.setDelegate(AppDelegate.new)
app.run

exit
