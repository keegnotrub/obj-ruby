require "bundler/setup"
Bundler.setup

require "obj_ruby"
require "obj_ruby/cocoa"

Dir["./spec/support/*.rb"].sort.each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
  config.order = :random

  def source_root
    File.join(__dir__, "support", "fixtures", "dummy")
  end

  def destination_root
    File.join(__dir__, "sandbox")
  end
end
