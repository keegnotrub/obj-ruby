require "mkmf"

dir_config("obj_ruby")

$LDFLAGS << " -lffi -framework Cocoa -Wl,-no_fixup_chains"

create_makefile("obj_ext")
