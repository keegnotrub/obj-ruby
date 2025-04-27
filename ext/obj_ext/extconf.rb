# frozen_string_literal: true

require "mkmf"

def abort_on_missing(missing)
  abort(<<~TXT.chomp)
    -----
    The #{missing} is missing in your build environment,
    which means you haven't installed Xcode Command Line Tools properly.

    To install Command Line Tools, try running `xcode-select --install` on
    terminal and follow the instructions. Otherwise, install Xcode from
    the macOS App Store.

    https://apps.apple.com/us/app/xcode/id497799835
    -----
  TXT
end

dir_config("obj_ruby")

abort_on_missing("Cocoa Framework") unless have_framework("Cocoa")
abort_on_missing("WebKit Framework") unless have_framework("WebKit")
abort_on_missing("ffi library") unless have_library("ffi")

if enable_config("debug", ENV["OBJR_BUILD_DEBUG"] == "true")
  append_cflags("-DNSDebugLog=NSLog")
end

create_makefile("obj_ext")
