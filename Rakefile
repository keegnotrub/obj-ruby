# frozen_string_literal: true

require "rake/extensiontask"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

Rake::ExtensionTask.new('obj_ext')
RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[compile spec]
