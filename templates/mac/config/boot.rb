require_relative "environment"

app = ObjRuby::NSApplication.sharedApplication
nib = ObjRuby::NSNib.alloc.initWithNibNamed_bundle("MainMenu", ObjRuby::NSBundle.bundleWithPath(ObjRuby.root("assets")))
nib.instantiateNibWithExternalNameTable(ObjRuby::NSNibOwner => app)

app.setActivationPolicy(ObjRuby::NSApplicationActivationPolicyRegular)
app.activateIgnoringOtherApps(true)
app.run

exit
