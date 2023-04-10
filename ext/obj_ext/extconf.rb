require 'mkmf'

dir_config('obj_ruby')

$DLDFLAGS << " -framework Foundation -framework AppKit"

create_makefile('obj_ext')

#system("mv -f Makefile Makefile.bak")
#system("sed -e 's/^\.c\.o:$/\.m\.o:/' Makefile.bak > Makefile")
#system("rm Makefile.bak")
