require_relative "environment"

app = ObjRuby::NSApplication.sharedApplication

ptr = ObjRuby::Ptr.new(:object)
nib = ObjRuby::NSNib.alloc.initWithNibNamed_bundle("MainMenu", ObjRuby::NSBundle.bundleWithPath(ObjRuby.root("assets")))
nib.instantiateWithOwner_topLevelObjects(app, ptr)

app.setActivationPolicy(ObjRuby::NSApplicationActivationPolicyRegular)
app.activateIgnoringOtherApps(true)
app.run

exit
