class AppDelegate
  def initialize
  end
  
  def applicationWillFinishLaunching(notification)
  end

  def applicationDidFinishLaunching(notification)
    ObjRuby::NSLog("im a here about to term")
    ObjRuby::NSApplication.sharedApplication.terminate(self)
  end

  def applicationShouldTerminate(sender)
    ObjRuby::NSLog("im a here and asking if I should")
    true
  end
end
