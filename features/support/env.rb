require 'rspec/expectations'
require 'aruba'
require 'aruba/config'
include RSpec::Matchers
require 'aruba/cucumber'


Before do
  @dirs = Dir.pwd
end

Before do
  @aruba_timeout_seconds = 240
end
