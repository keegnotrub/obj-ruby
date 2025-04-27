# frozen_string_literal: true

require "rake/clean"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "bundler/gem_tasks"

RSpec::Core::RakeTask.new
RuboCop::RakeTask.new

CLOBBER.include("tmp")

namespace "compile" do
  desc ""
  task :default do
    build
  end
  desc "Compile obj_ext.bundle into the lib directory with debug enabled"
  task :debug do
    build("--enable-debug")
  end
end

desc "Compile obj_ext.bundle into the lib directory"
task compile: ["compile:default"]

task default: %i[compile spec]

def build(options = "")
  tmp = File.expand_path("tmp", __dir__)
  FileUtils.mkdir_p(tmp)
  FileUtils.chdir(tmp) do
    system(Gem.ruby, File.expand_path("ext/obj_ext/extconf.rb", __dir__), options, exception: true)
    system("make clean", exception: true)
    system("make", exception: true)
    system("make install sitearchdir=../lib sitelibdir=../lib target_prefix=", exception: true)
  end
end
