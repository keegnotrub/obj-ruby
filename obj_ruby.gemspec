Gem::Specification.new do |s|
  s.name        = 'obj_ruby'
  s.version     = '1.0.0'
  s.authors     = ['Ryan Krug']
  s.email       = ['support@thoughtbot.com']
  s.homepage    = 'http://github.com/keegnotrub/obj_ruby'
  s.summary     = 'Ruby to Objective-C bridge'
  s.description = 'Like RubyCocoa, but not RubyCocoa.'
  s.license     = 'MIT'

  s.files            = `git ls-files -- {ext,lib}/*`.split("\n")
  s.require_paths    = ["lib"]
  s.extensions       = ["ext/obj_ext/extconf.rb"]

  s.add_development_dependency('rake-compiler')
  s.add_development_dependency('rspec')
  s.add_development_dependency('standard')
end
