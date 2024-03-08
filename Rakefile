# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"

RSpec::Core::RakeTask.new(:spec)

desc "Compile obj_ext.bundle locally for lib"
task :compile do
  Dir.chdir(File.expand_path("tmp", __dir__)) do
    extconf = File.expand_path("ext/obj_ext/extconf.rb", __dir__)
        
    system(Gem.ruby, extconf) &&
      system("make install sitearchdir=../lib sitelibdir=../lib target_prefix=")
  end
end

task default: [:standard, :compile, :spec]
