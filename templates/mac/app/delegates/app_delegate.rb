class AppDelegate < ObjRuby::NSObject
  ib_outlet :window
  ib_action :openTutorial

  def openTutorial(sender)
    ObjRuby::NSWorkspace.sharedWorkspace.openURL(ObjRuby::NSURL.URLWithString("https://github.com/keegnotrub/obj-ruby"))
  end

  def applicationWillFinishLaunching(_)
    ObjRuby::NSLog("applicationWillFinishLaunching:")
  end

  def applicationDidFinishLaunching(_)
    ObjRuby::NSLog("applicationDidFinishLaunching:")
    window.center
  end

  def applicationShouldTerminateAfterLastWindowClosed(_)
    ObjRuby::NSLog("applicationShouldTerminateAfterLastWindowClosed:")
    true
  end
end
