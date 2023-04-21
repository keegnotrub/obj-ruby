require 'mkmf'

dir_config('obj_ruby')

$DLDFLAGS << " -framework Foundation -framework AppKit"

create_makefile('obj_ext')
