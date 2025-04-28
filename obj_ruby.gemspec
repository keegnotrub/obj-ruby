# frozen_string_literal: true

require_relative "lib/obj_ruby/version"

Gem::Specification.new do |s|
  s.name = "obj_ruby"
  s.version = ObjRuby::VERSION
  s.authors = ["Ryan Krug"]
  s.email = ["ryank@kit.com"]
  s.homepage = "http://github.com/keegnotrub/obj_ruby"
  s.summary = "Ruby to Objective-C bridge"
  s.description = "A fork of GNUstep's RIGS, updated for modern verions of macOS and Ruby."
  s.license = "LGPL-2.1"

  s.metadata = { "rubygems_mfa_required" => "true" }

  s.files = `git ls-files -- {ext,lib}/*`.split("\n")
  s.require_paths = ["lib"]
  s.extensions = ["ext/obj_ext/extconf.rb"]

  s.platform = Gem::Platform.new("darwin")
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.10")
end
