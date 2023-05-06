require 'mkmf'

dir_config('obj_ruby')

$LDFLAGS << " -framework Foundation -framework AppKit"

create_makefile('obj_ext')
