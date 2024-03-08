require "mkmf"

dir_config("obj_ruby")

unless have_framework("Cocoa")
  abort("Cocoa framework could not be found, please install and try again")
end

unless have_library("ffi")
  abort("ffi library could not be found, please install and try again")
end

if enable_config("debug")
  append_cflags("-DNSDebugLog=NSLog")
end

create_makefile("obj_ext")
