Gem::Specification.new do |s|
  s.name        = "obj_ruby"
  s.version     = "0.1.0"
  s.authors     = ["Ryan Krug"]
  s.email       = ["ryan.krug@thoughtbot.com"]
  s.homepage    = "http://github.com/keegnotrub/obj_ruby"
  s.summary     = "Ruby to Objective-C bridge"
  s.description = "A fork of GNUstep's RIGS, updated for modern verions of macOS and Ruby."
  s.license     = "LGPL-2.1"

  s.files            = `git ls-files -- {ext,lib}/*`.split("\n")
  s.require_paths    = ["lib"]
  s.extensions       = ["ext/obj_ext/extconf.rb"]

  s.add_development_dependency('rake-compiler')
  s.add_development_dependency('rspec')
  s.add_development_dependency('standard')
end
