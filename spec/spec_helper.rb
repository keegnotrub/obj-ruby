require "bundler/setup"
Bundler.setup

require "obj_ruby"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
  config.order = :random
end
