ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)
ENV["OBJR_ROOT"] ||= File.expand_path("..", __dir__)

require "bundler/setup"

require "obj_ruby"
require "obj_ruby/cocoa"

ObjRuby.initialize!
