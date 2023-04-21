require "bundler/setup"
Bundler.setup

require "obj_ruby"
require "AppKit"

app = NSApplication.sharedApplication
app.setActivationPolicy(NSApplicationActivationPolicyRegular)

mainMenu = NSMenu.new

mainMenuItem = NSMenuItem.new
mainMenu.addItem(mainMenuItem)

appMenu = NSMenu.alloc.initWithTitle("ObjRuby")
quitMenuItem = NSMenuItem.alloc.initWithTitle_action_keyEquivalent("Quit ObjRuby", "terminate:", "q")
appMenu.addItem(quitMenuItem)
mainMenuItem.setSubmenu(appMenu)

app.setMainMenu(mainMenu)

window = NSWindow.alloc.initWithContentRect_styleMask_backing_defer(NSRect.new(0, 0, 200, 200),
  NSWindowStyleMaskTitled,
  NSBackingStoreBuffered,
  false)
window.cascadeTopLeftFromPoint(NSPoint.new(20, 20))
window.setTitle("ObjRuby")
window.makeKeyAndOrderFront(nil)

app.activateIgnoringOtherApps(true)

app.run
