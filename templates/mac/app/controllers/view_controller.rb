class ViewController < ObjRuby::NSViewController
  def init
    initWithNibName_bundle(nil, nil)
  end

  def loadView
    view = ObjRuby::NSView.alloc.initWithFrame(ObjRuby::NSMakeRect(0, 0, 600, 400))
    
    label = ObjRuby::NSTextView.new
    label.setTranslatesAutoresizingMaskIntoConstraints(false)

    attrs = {
      ObjRuby::NSLinkAttributeName => ObjRuby::NSURL.URLWithString("https://www.apple.com"),
      ObjRuby::NSForegroundColorAttributeName => ObjRuby::NSColor.linkColor,
      ObjRuby::NSUnderlineStyleAttributeName => ObjRuby::NSSingleUnderlineStyle
    }

    text = ObjRuby::NSAttributedString.alloc.initWithString_attributes("Apple Computer", attrs)

    label.textStorage.setAttributedString(text)
    label.setEditable(false)
    label.setBackgroundColor(ObjRuby::NSColor.clearColor)

    view.addSubview(label)

    view.addConstraint(
      ObjRuby::NSLayoutConstraint.constraintWithItem_attribute_relatedBy_toItem_attribute_multiplier_constant(
        label,
        ObjRuby::NSLayoutAttributeCenterX,
        ObjRuby::NSLayoutRelationEqual,
        view,
        ObjRuby::NSLayoutAttributeCenterX,
        1,
        0
      )
    )
    view.addConstraint(
      ObjRuby::NSLayoutConstraint.constraintWithItem_attribute_relatedBy_toItem_attribute_multiplier_constant(
        label,
        ObjRuby::NSLayoutAttributeCenterY,
        ObjRuby::NSLayoutRelationEqual,
        view,
        ObjRuby::NSLayoutAttributeCenterY,
        1,
        0
      )
    )

    label.layoutManager.ensureLayoutForTextContainer(label.textContainer)
    rect = label.layoutManager.usedRectForTextContainer(label.textContainer)

    view.addConstraints(
      ObjRuby::NSLayoutConstraint.constraintsWithVisualFormat_options_metrics_views(
        "H:[label(#{rect.size.width})]",
        nil,
        nil,
        { "label" => label }
      )
    )
    view.addConstraints(
      ObjRuby::NSLayoutConstraint.constraintsWithVisualFormat_options_metrics_views(
        "V:[label(#{rect.size.height})]",
        nil,
        nil,
        { "label" => label }
      )
    )

    setView(view)
  end

  #def viewDidLoad
    #view.setWantsLayer(true)
    #view.layer.setBackgroundColor(ObjRuby::NSColor.redColor.CGColor)
  #end
end
