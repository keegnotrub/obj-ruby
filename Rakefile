# frozen_string_literal: true

require "rake/clean"
require "standard/rake"
require "rspec/core/rake_task"
require "bundler/gem_tasks"

CLOBBER.include("tmp")

desc "Compile obj_ext.bundle into the lib directory"
task :compile do
  tmp = File.expand_path("tmp", __dir__)
  extconf = File.expand_path("ext/obj_ext/extconf.rb", __dir__)

  if !Dir.exist?(tmp)
    Dir.mkdir(tmp)
  end

  Dir.chdir(tmp) do
    system(Gem.ruby, extconf, exception: true)
    system("make clean", exception: true)
    system("make", exception: true)
    system("make install sitearchdir=../lib sitelibdir=../lib target_prefix=", exception: true)
  end
end

RSpec::Core::RakeTask.new(:spec)

task default: [:compile, :spec]
