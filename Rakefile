# frozen_string_literal: true

require "rake/extensiontask"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"

Rake::ExtensionTask.new("obj_ext") do |ext|
  ext.source_pattern = "*.m"
end

RSpec::Core::RakeTask.new(:spec)

task default: [:standard, :compile, :spec]
