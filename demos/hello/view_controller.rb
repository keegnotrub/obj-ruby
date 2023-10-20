class ViewController < ObjRuby::NSViewController
  def init
    initWithNibName_bundle(nil, nil)
  end

  def loadView
    setView(ObjRuby::NSView.alloc.initWithFrame(ObjRuby::NSMakeRect(0, 0, 600, 400)))
  end

  def viewDidLoad
    view.setWantsLayer(true)
    view.layer.setBackgroundColor(ObjRuby::NSColor.redColor.CGColor)
  end
end
