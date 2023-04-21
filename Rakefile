# frozen_string_literal: true

require "rake/extensiontask"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"

Rake::ExtensionTask.new('obj_ext')
RSpec::Core::RakeTask.new(:spec)

task default: [:compile, :spec]
