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
end
