class AppDelegate < ObjRuby::NSObject
  def applicationWillFinishLaunching(notification)
    @window_controller = WindowController.alloc.init
  end

  def applicationDidFinishLaunching(notification)
    @window_controller.showWindow(self)
  end

  def applicationShouldTerminateAfterLastWindowClosed(application)
    true
  end
end
