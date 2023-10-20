class WindowController < ObjRuby::NSWindowController
  def init
    style_mask = ObjRuby::NSTitledWindowMask | ObjRuby::NSClosableWindowMask |
      ObjRuby::NSMiniaturizableWindowMask | ObjRuby::NSResizableWindowMask
    @window = ObjRuby::NSWindow.alloc
    @window.initWithContentRect_styleMask_backing_defer(ObjRuby::NSZeroRect, style_mask, ObjRuby::NSBackingStoreRetained, false)

    @window.setDelegate(self)
    @window.setContentViewController(ViewController.alloc.init)

    @window.center

    initWithWindow(@window)
  end
end
