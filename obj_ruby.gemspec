$LOAD_PATH << File.expand_path("lib", __dir__)
require "obj_ruby/version"

Gem::Specification.new do |s|
  s.name = "obj_ruby"
  s.version = ObjRuby::VERSION
  s.authors = ["Ryan Krug"]
  s.email = ["ryan.krug@thoughtbot.com"]
  s.homepage = "http://github.com/keegnotrub/obj_ruby"
  s.summary = "Ruby to Objective-C bridge"
  s.description = "A fork of GNUstep's RIGS, updated for modern verions of macOS and Ruby."
  s.license = "LGPL-2.1"

  s.files = `git ls-files -- {ext,lib}/*`.split("\n")
  s.require_paths = ["lib"]
  s.extensions = ["ext/obj_ext/extconf.rb"]

  s.platform = Gem::Platform.new("darwin")
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  s.add_runtime_dependency("zeitwerk")
  s.add_runtime_dependency("thor")

  s.add_development_dependency("rake-compiler", "~> 1.0")
  s.add_development_dependency("rspec", "~> 3.0")
  s.add_development_dependency("standard", "~> 1.0")
end
