class AppDelegate
  def initialize
    @window = ObjRuby::NSWindow.alloc
  end

  def applicationWillFinishLaunching(notification)
	  rect = ObjRuby::NSMakeRect(0, 0, 400, 200)
	  styleMask = ObjRuby::NSTitledWindowMask | ObjRuby::NSClosableWindowMask |
	              ObjRuby::NSMiniaturizableWindowMask | ObjRuby::NSResizableWindowMask

	  @window.initWithContentRect_styleMask_backing_defer(rect, styleMask, ObjRuby::NSBackingStoreRetained, false)
	  @window.setTitle("ObjRuby")
  end

  def applicationDidFinishLaunching(notification)
    @window.center()
	  @window.makeKeyAndOrderFront(self)
  end

  def applicationShouldTerminateAfterLastWindowClosed(application)
    true
  end
end
